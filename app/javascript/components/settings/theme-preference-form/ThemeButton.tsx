import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { GenericTooltip } from '@/components/misc/ExercismTippy'
import { isButtonDisabled } from './utils'
import type { Theme, ThemePreferenceLinks } from '../ThemePreferenceForm'
import { DisabledThemeSelectorTooltip } from '@/components/common/ThemeToggleButton'

const THEME_BUTTON_SIZE = 130
export function ThemeButton({
  theme,
  currentTheme,
  onClick,
  disabledInfo,
  links,
}: {
  theme: Theme
  onClick: React.MouseEventHandler<HTMLButtonElement>
  currentTheme: string
  disabledInfo: isButtonDisabled
  links: ThemePreferenceLinks
}): JSX.Element {
  const selected = theme.value === currentTheme

  const nonPremium = disabledInfo.level === 'non-premium'
  const { disabled } = disabledInfo

  return (
    <GenericTooltip
      interactive
      disabled={!nonPremium}
      content={
        nonPremium && (
          <DisabledThemeSelectorTooltip premiumLink={links.premiumPath} />
        )
      }
    >
      <div className="flex flex-col gap-16 items-center">
        <button
          type="submit"
          disabled={disabled}
          value={theme.value}
          id={`${theme.value}-theme`}
          style={{
            height: `${THEME_BUTTON_SIZE}px`,
            width: `${THEME_BUTTON_SIZE}px`,
            background: `${theme.background}`,
            filter: nonPremium ? 'grayscale(0.9)' : '',
            opacity: nonPremium ? '60%' : '100%',
          }}
          className={`flex items-center justify-center border-1 border-borderColor6 rounded-8 ${
            selected && '--selected-theme'
          } ${theme.value === 'sepia' && 'sepia'}`}
          onClick={onClick}
        >
          <GraphicalIcon
            icon={nonPremium ? 'lock-circle' : theme.icon}
            height={64}
            width={64}
          />
        </button>
        <label
          className="text-p text-15 font-semibold"
          style={{ filter: nonPremium ? 'grayscale(0.9)' : '' }}
          htmlFor={`${theme.value}-theme`}
        >
          {theme.label}
        </label>
      </div>
    </GenericTooltip>
  )
}
