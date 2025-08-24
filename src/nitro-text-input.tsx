// biome-ignore lint/correctness/noUnusedImports: Needed for JSX runtime
import React, { type FC } from 'react'
import type { NitroTextInputViewProps } from './specs/text-input-view.nitro'
import { NitroTextInput } from './native-nitro-text-input'
import type { StyleProp, ViewStyle } from 'react-native'

interface NitroTextInputProps extends NitroTextInputViewProps {
  style?: StyleProp<ViewStyle>
}

export const NitroInput: FC<NitroTextInputProps> = ({
  onChangeText,
  ...props
}) => {
  return <NitroTextInput {...props} onChangeText={{ f: onChangeText }} />
}
