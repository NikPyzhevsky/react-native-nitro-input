import { getHostComponent } from 'react-native-nitro-modules'
import ViewConfig from '../nitrogen/generated/shared/json/NitroTextInputViewConfig.json'
import type {
  NitroTextInputViewMethods,
  NitroTextInputViewProps,
} from './specs/text-input-view.nitro'

export const NitroTextInput = getHostComponent<
  NitroTextInputViewProps,
  NitroTextInputViewMethods
>('NitroTextInputView', () => ViewConfig)
