import { window } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'

export async function hideSystemBars(uiContext: UIContext): Promise<void> {
  try {
    let context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext
    let lastWindow: window.Window = await window.getLastWindow(context)
    await lastWindow.setWindowLayoutFullScreen(true)
    await lastWindow.setSpecificSystemBarEnabled('status', false)
    await lastWindow.setSpecificSystemBarEnabled('navigationIndicator', false)
  } catch (err) {
    console.error('hideSystemBars failed')
  }
}

export async function showSystemBars(uiContext: UIContext): Promise<void> {
  try {
    let context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext
    let lastWindow: window.Window = await window.getLastWindow(context)
    await lastWindow.setSpecificSystemBarEnabled('status', true)
    await lastWindow.setSpecificSystemBarEnabled('navigationIndicator', true)
  } catch (err) {
    console.error('showSystemBars failed')
  }
}
