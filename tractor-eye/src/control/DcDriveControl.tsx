import { useId } from 'react'

const presets = [25, 50, 75, 100]

export function DcDriveControl({ value, onChange }: {
  value: number
  onChange: (value: number) => void
}) {
  const id = useId()
  return (
    <div className="dc-drive">
      <div className="dc-drive-heading">
        <label htmlFor={id}>Drive (PWM)</label>
        <output htmlFor={id}>{value} / 255 · {(value / 255 * 100).toFixed(1)}%</output>
      </div>
      <input id={id} type="range" min="1" max="255" step="1" value={value}
        aria-valuetext={`${value} of 255, ${(value / 255 * 100).toFixed(1)} percent drive`}
        onChange={event => onChange(Number(event.currentTarget.value))} />
      <div className="dc-presets" aria-label="PWM presets">
        {presets.map(percent => {
          const duty = Math.round(percent / 100 * 255)
          return <button key={percent} type="button" aria-pressed={value === duty}
            onClick={() => onChange(duty)}>{percent}%</button>
        })}
      </div>
    </div>
  )
}
