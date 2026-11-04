import React from 'react';
import Svg, { Path, Circle, Rect, Line } from 'react-native-svg';

/** Own icon set: 24px grid, 1.75 stroke, rounded caps. Never emoji. */
export type IconName = 'home' | 'list' | 'cart' | 'plan' | 'more' | 'plus' | 'check' | 'close' | 'chevron-right' | 'chevron-left' | 'chevron-up' | 'chevron-down' | 'wallet' | 'card' | 'calendar' | 'tag' | 'search' | 'eye' | 'eye-off' | 'camera' | 'barcode' | 'flash' | 'flash-off' | 'settings' | 'info' | 'alert' | 'trash' | 'edit' | 'arrow-up' | 'arrow-down' | 'swap' | 'target' | 'bank' | 'receipt' | 'help' | 'lock' | 'download' | 'upload' | 'sparkle' | 'drag' | 'star' | 'moon' | 'sun';

const paths: Record<IconName, React.ReactNode> = {
  home: <Path d="M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z" />,
  list: <><Path d="M8 6h13M8 12h13M8 18h13" /><Circle cx="4" cy="6" r="1" /><Circle cx="4" cy="12" r="1" /><Circle cx="4" cy="18" r="1" /></>,
  cart: <><Path d="M3 4h2l2.4 11.2a1 1 0 0 0 1 .8h9.7a1 1 0 0 0 1-.8L21 8H6" /><Circle cx="9" cy="20" r="1.2" /><Circle cx="17" cy="20" r="1.2" /></>,
  plan: <><Circle cx="12" cy="12" r="9" /><Path d="M12 7v5l3.5 2" /></>,
  more: <><Circle cx="5" cy="12" r="1.2" /><Circle cx="12" cy="12" r="1.2" /><Circle cx="19" cy="12" r="1.2" /></>,
  plus: <Path d="M12 5v14M5 12h14" />,
  check: <Path d="M5 12.5l4.5 4.5L19 7.5" />,
  close: <Path d="M6 6l12 12M18 6L6 18" />,
  'chevron-right': <Path d="M9 6l6 6-6 6" />,
  'chevron-left': <Path d="M15 6l-6 6 6 6" />,
  'chevron-up': <Path d="M6 15l6-6 6 6" />,
  'chevron-down': <Path d="M6 9l6 6 6-6" />,
  wallet: <><Rect x="3" y="6" width="18" height="13" rx="3" /><Path d="M3 10h18M16 14.5h2" /></>,
  card: <><Rect x="2" y="5" width="20" height="14" rx="3" /><Path d="M2 10h20M6 15h4" /></>,
  calendar: <><Rect x="3" y="5" width="18" height="16" rx="3" /><Path d="M3 10h18M8 3v4M16 3v4" /></>,
  tag: <><Path d="M3 12V4h8l9 9-8 8z" /><Circle cx="7.5" cy="8.5" r="1.2" /></>,
  search: <><Circle cx="11" cy="11" r="6.5" /><Path d="M16 16l4.5 4.5" /></>,
  eye: <><Path d="M2.5 12s3.5-6 9.5-6 9.5 6 9.5 6-3.5 6-9.5 6-9.5-6-9.5-6z" /><Circle cx="12" cy="12" r="2.8" /></>,
  'eye-off': <><Path d="M3 3l18 18M10.6 6.3A10 10 0 0 1 12 6c6 0 9.5 6 9.5 6a16 16 0 0 1-3.2 3.8M6.6 6.6A16 16 0 0 0 2.5 12s3.5 6 9.5 6a9 9 0 0 0 3.6-.7" /></>,
  camera: <><Path d="M4 8h3l1.5-2h7L17 8h3a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1z" /><Circle cx="12" cy="13" r="3.2" /></>,
  barcode: <Path d="M4 6v12M8 6v12M11 6v12M14 6v12M17 6v12M20 6v12" />,
  flash: <Path d="M13 2L5 13h6l-1 9 8-11h-6z" />,
  'flash-off': <><Path d="M13 2L8.5 8.2M5 13h6l-1 9 4.8-6.6M3 3l18 18M12.5 9H18l-2.6 3.6" /></>,
  settings: <><Circle cx="12" cy="12" r="3" /><Path d="M12 2.5v3M12 18.5v3M2.5 12h3M18.5 12h3M5.3 5.3l2.1 2.1M16.6 16.6l2.1 2.1M5.3 18.7l2.1-2.1M16.6 7.4l2.1-2.1" /></>,
  info: <><Circle cx="12" cy="12" r="9" /><Path d="M12 11v5M12 8v.5" /></>,
  alert: <><Path d="M12 3l9.5 16.5h-19z" /><Path d="M12 10v4M12 17v.5" /></>,
  trash: <><Path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13" /></>,
  edit: <Path d="M4 20h4l10.5-10.5a2 2 0 0 0 0-2.8l-1.2-1.2a2 2 0 0 0-2.8 0L4 16z" />,
  'arrow-up': <Path d="M12 19V5M6 11l6-6 6 6" />,
  'arrow-down': <Path d="M12 5v14M6 13l6 6 6-6" />,
  swap: <Path d="M7 7h13m-4-4 4 4-4 4M17 17H4m4-4-4 4 4 4" />,
  target: <><Circle cx="12" cy="12" r="9" /><Circle cx="12" cy="12" r="5" /><Circle cx="12" cy="12" r="1.2" /></>,
  bank: <><Path d="M3 10l9-6 9 6M5 10v8M9 10v8M15 10v8M19 10v8M3 20h18" /></>,
  receipt: <><Path d="M6 3h12v18l-2-1.5-2 1.5-2-1.5-2 1.5-2-1.5L6 21z" /><Path d="M9 8h6M9 12h6" /></>,
  help: <><Circle cx="12" cy="12" r="9" /><Path d="M9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.7.3-1 .8-1 1.7M12 17v.5" /></>,
  lock: <><Rect x="5" y="11" width="14" height="10" rx="2" /><Path d="M8 11V8a4 4 0 0 1 8 0v3" /></>,
  download: <Path d="M12 4v11M7 10l5 5 5-5M4 20h16" />,
  upload: <Path d="M12 15V4M7 9l5-5 5 5M4 20h16" />,
  sparkle: <Path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8zM19 16l.8 2.2L22 19l-2.2.8L19 22l-.8-2.2L16 19l2.2-.8z" />,
  drag: <><Circle cx="9" cy="7" r="1.2" /><Circle cx="15" cy="7" r="1.2" /><Circle cx="9" cy="12" r="1.2" /><Circle cx="15" cy="12" r="1.2" /><Circle cx="9" cy="17" r="1.2" /><Circle cx="15" cy="17" r="1.2" /></>,
  star: <Path d="M12 3.5l2.6 5.4 5.9.8-4.3 4.1 1.1 5.9L12 16.9l-5.3 2.8 1.1-5.9-4.3-4.1 5.9-.8z" />,
  moon: <Path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z" />,
  sun: <><Circle cx="12" cy="12" r="4" /><Path d="M12 2.5v2M12 19.5v2M2.5 12h2M19.5 12h2M5.3 5.3l1.4 1.4M17.3 17.3l1.4 1.4M5.3 18.7l1.4-1.4M17.3 6.7l1.4-1.4" /></>,
};

export function Icon({ name, size = 24, color = '#162022', filled }: { name: IconName; size?: number; color?: string; filled?: boolean }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill={filled ? color : 'none'} stroke={color} strokeWidth={1.75} strokeLinecap="round" strokeLinejoin="round" accessibilityElementsHidden importantForAccessibility="no">
      {paths[name]}
    </Svg>
  );
}

export const _unused = Line; // keep import for future icons
