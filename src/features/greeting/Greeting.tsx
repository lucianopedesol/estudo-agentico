import { useAppContext } from '../../context/AppContext'
import { GreetingWrapper, GreetingTitle } from './Greeting.styles'

export function Greeting() {
  const { userName } = useAppContext()
  return (
    <GreetingWrapper>
      <GreetingTitle>Olá, {userName}!</GreetingTitle>
      <p>Esse é o primeiro pedaço do projeto de estudo agentico.</p>
    </GreetingWrapper>
  )
}
