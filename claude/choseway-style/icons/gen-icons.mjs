// 从 coolicons 仓库抽取选定图标的 path 数据，生成两个项目共用的 Icon.tsx，
// 并把源 SVG 复制到 choseway-style 技能目录作为单一来源。
import { readFileSync, writeFileSync, mkdirSync, copyFileSync } from 'node:fs';
import { join } from 'node:path';

const SRC = String.raw`C:\Users\STQ\AppData\Local\Temp\claude\W--Project-AI-AI-ChoseWayManager\65cc72f4-3794-4ff1-ba35-6222678c751e\scratchpad\coolicons\coolicons SVG`;

// kebab 名 → coolicons 源文件（相对 coolicons SVG/）
const MAP = {
  'house': 'Navigation/House_01.svg',
  'kanban': 'Edit/Columns.svg',
  'gantt': 'Interface/Chart_Bar_Horizontal_01.svg',
  'archive': 'File/Archive.svg',
  'lock': 'Interface/Lock.svg',
  'users': 'User/Users_Group.svg',
  'user': 'User/User_01.svg',
  'settings': 'Interface/Settings.svg',
  'shield': 'Shape/Shield.svg',
  'log-out': 'Interface/Log_Out.svg',
  'close': 'Menu/Close_MD.svg',
  'check': 'Interface/Check.svg',
  'caret-down': 'Arrow/Caret_Down_SM.svg',
  'caret-up': 'Arrow/Caret_Up_SM.svg',
  'arrow-up': 'Arrow/Arrow_Up_SM.svg',
  'arrow-down': 'Arrow/Arrow_Down_SM.svg',
  'chevrons-left': 'Arrow/Chevron_Left_Duo.svg',
  'chevrons-right': 'Arrow/Chevron_Right_Duo.svg',
  'download': 'Interface/Download.svg',
  'folders': 'File/Folders.svg',
  'trash': 'Interface/Trash_Empty.svg',
  'trash-full': 'Interface/Trash_Full.svg',
  'warning': 'Warning/Triangle_Warning.svg',
};

const entries = [];
for (const [name, rel] of Object.entries(MAP)) {
  const raw = readFileSync(join(SRC, rel), 'utf8');
  // 只允许 path 元素；抽取全部 d 属性
  const tags = [...raw.matchAll(/<(?!\/)([a-zA-Z]+)[\s>]/g)].map(m => m[1]).filter(t => !['svg', 'g', 'path'].includes(t));
  if (tags.length) throw new Error(`${rel} 含非 path 元素: ${tags.join(',')}`);
  const ds = [...raw.matchAll(/\sd="([^"]+)"/g)].map(m => m[1]);
  if (!ds.length) throw new Error(`${rel} 未找到 path`);
  entries.push({ name, rel, ds });
}

const names = entries.map(e => `'${e.name}'`).join(' | ');
const dict = entries.map(e => `  '${e.name}': [${e.ds.map(d => `'${d}'`).join(', ')}],`).join('\n');

const tsx = `// 统一图标组件 —— 图标源：coolicons v4.1（https://github.com/krystonschwarze/coolicons，CC BY 4.0）
// 由 AI_Skills/claude/choseway-style/icons/gen-icons.mjs 生成，勿手改路径数据；增删图标改脚本重新生成。
// 24×24 线性描边，stroke 用 currentColor 随主题着色；千往控制台与报价平台共用同一份。
import type { CSSProperties } from 'react';

export type IcoName = ${names};

const P: Record<IcoName, string[]> = {
${dict}
};

export function Ico(props: { name: IcoName; size?: number; className?: string; style?: CSSProperties; title?: string }) {
  const size = props.size ?? 18;
  return (
    <svg
      // 文字旁内联时基线微调；flex / .ico 容器里由容器居中，此值被忽略，无副作用
      className={props.className} style={{ verticalAlign: '-0.18em', ...props.style }} width={size} height={size}
      viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2}
      strokeLinecap="round" strokeLinejoin="round" aria-hidden={props.title ? undefined : true}
    >
      {props.title ? <title>{props.title}</title> : null}
      {P[props.name].map((d, i) => <path key={i} d={d} />)}
    </svg>
  );
}
`;

const OUTS = [
  String.raw`W:\Project\AI\AI_ChoseWayManager\web\src\components\Icon.tsx`,
  String.raw`W:\Project\AI\AI_报价单生成工具\web\src\components\Icon.tsx`,
];
for (const out of OUTS) writeFileSync(out, tsx, 'utf8');

// 复制源 SVG 到技能目录（单一来源）
const SKILL = String.raw`W:\Project\AI\AI_Skills\claude\choseway-style\icons`;
mkdirSync(SKILL, { recursive: true });
for (const e of entries) copyFileSync(join(SRC, e.rel), join(SKILL, `${e.name}.svg`));

console.log(`OK：${entries.length} 个图标 → Icon.tsx ×2 + 技能目录 SVG`);
