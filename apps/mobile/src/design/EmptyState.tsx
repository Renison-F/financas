import React from 'react';
import { View } from 'react-native';
import { Text } from './Text';
import { Button } from './Button';
import { Icon, type IconName } from './icons';
import { useColors } from './theme';
import { spacing } from './tokens';

export function EmptyState({ icon = 'info', title, text, actionTitle, onAction, testID }: { icon?: IconName | undefined; title: string; text?: string | undefined; actionTitle?: string | undefined; onAction?: (() => void) | undefined; testID?: string | undefined }) {
  const c = useColors();
  return (
    <View testID={testID} style={{ alignItems: 'center', paddingVertical: spacing.lg, gap: spacing.xs }}>
      <View style={{ width: 48, height: 48, borderRadius: 24, backgroundColor: c.surfaceInset, alignItems: 'center', justifyContent: 'center' }}><Icon name={icon} color={c.textMuted} /></View>
      <Text role="title" align="center">{title}</Text>
      {text ? <Text role="bodySmall" color="textMuted" align="center" style={{ maxWidth: 320 }}>{text}</Text> : null}
      {actionTitle && onAction ? <Button title={actionTitle} onPress={onAction} variant="secondary" style={{ marginTop: spacing.xs }} /> : null}
    </View>
  );
}

export function ErrorState({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return <EmptyState icon="alert" title="Algo deu errado" text={message} actionTitle={onRetry ? 'Tentar de novo' : undefined} onAction={onRetry} />;
}
