import { useState } from 'react'
import { useAppContext } from '../../context/AppContext'
import { GreetingWrapper, GreetingTitle, NameInput, CharCount } from './Greeting.styles'

export function Greeting() {
  const { userName, setUserName } = useAppContext()
  const [rawValue, setRawValue] = useState('')

  function handleChange(event: React.ChangeEvent<HTMLInputElement>) {
    const value = event.target.value
    setRawValue(value)
    setUserName(value.trim() === '' ? 'visitante' : value)
  }

  return (
    <GreetingWrapper>
      <GreetingTitle>Olá, {userName}!</GreetingTitle>
      <NameInput
        type="text"
        placeholder="Digite seu nome"
        aria-label="Seu nome"
        onChange={handleChange}
      />
      <CharCount>{rawValue.length} caracteres</CharCount>
      <p>Esse é o primeiro pedaço do projeto de estudo agentico.</p>
    </GreetingWrapper>
  )
}
