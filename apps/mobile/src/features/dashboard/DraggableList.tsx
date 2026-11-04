import React, { useRef } from 'react';
import { View, type LayoutChangeEvent } from 'react-native';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import Animated, { useSharedValue, useAnimatedStyle, runOnJS, withTiming } from 'react-native-reanimated';
import { Icon, useColors, touch } from '../../design';

/**
 * Long-press drag-and-drop reordering built on gesture-handler + reanimated. Items are moved in the
 * array when the dragged item crosses a neighbour's midpoint. Accessible alternative: the arrow buttons
 * rendered by the caller.
 */
export function DraggableList<T extends string>({ items, onReorder, renderItem }: { items: T[]; onReorder: (next: T[]) => void; renderItem: (item: T, index: number, dragHandle: React.ReactNode) => React.ReactNode }) {
  const heights = useRef<Record<string, number>>({});
  return <View>{items.map((item, index) => <DraggableRow key={item} id={item} index={index} items={items} heights={heights} onReorder={onReorder}>{(handle) => renderItem(item, index, handle)}</DraggableRow>)}</View>;
}

function DraggableRow<T extends string>({ id, index, items, heights, onReorder, children }: { id: T; index: number; items: T[]; heights: React.MutableRefObject<Record<string, number>>; onReorder: (next: T[]) => void; children: (handle: React.ReactNode) => React.ReactNode }) {
  const c = useColors();
  const translateY = useSharedValue(0);
  const active = useSharedValue(false);
  const move = (delta: number) => {
    const to = Math.max(0, Math.min(items.length - 1, index + delta));
    if (to === index) return;
    const next = [...items]; next.splice(index, 1); next.splice(to, 0, id); onReorder(next);
  };
  const rowHeight = () => heights.current[id] ?? 64;
  const gesture = Gesture.Pan().activateAfterLongPress(220)
    .onStart(() => { active.value = true; })
    .onUpdate((e) => { translateY.value = e.translationY; })
    .onEnd(() => {
      const h = rowHeight();
      const delta = Math.round(translateY.value / h);
      translateY.value = withTiming(0, { duration: 120 });
      active.value = false;
      if (delta !== 0) runOnJS(move)(delta);
    });
  const style = useAnimatedStyle(() => ({ transform: [{ translateY: translateY.value }, { scale: active.value ? 1.02 : 1 }], zIndex: active.value ? 10 : 0, opacity: active.value ? 0.9 : 1 }));
  const handle = (
    <GestureDetector gesture={gesture}>
      <View accessible accessibilityLabel="Arrastar para reordenar" accessibilityHint="Segure e arraste para cima ou para baixo" style={{ width: touch.min, height: touch.min, alignItems: 'center', justifyContent: 'center' }}><Icon name="drag" color={c.textMuted} /></View>
    </GestureDetector>
  );
  return <Animated.View style={style} onLayout={(e: LayoutChangeEvent) => { heights.current[id] = e.nativeEvent.layout.height; }}>{children(handle)}</Animated.View>;
}
