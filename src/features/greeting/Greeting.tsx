import { useAppContext } from '../../context/AppContext'
import { GreetingWrapper, GreetingTitle, NameInput } from './Greeting.styles'

export function Greeting() {
  const { userName, setUserName } = useAppContext()

  function handleChange(event: React.ChangeEvent<HTMLInputElement>) {
    const value = event.target.value
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
      <p>Esse é o primeiro pedaço do projeto de estudo agentico.</p>
    </GreetingWrapper>
  )
}
