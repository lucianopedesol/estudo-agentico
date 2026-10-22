import { useState } from 'react'
import { BioTextArea } from './Bio.styles'

export function Bio() {
  const [bio, setBio] = useState('')

  return (
    <BioTextArea
      value={bio}
      onChange={(event) => setBio(event.target.value)}
      placeholder="Escreva algo sobre você..."
      rows={3}
      aria-label="Bio"
    />
  )
}
