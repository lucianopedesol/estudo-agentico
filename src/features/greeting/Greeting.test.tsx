import { render, screen } from '@testing-library/react'
import { AppProvider } from '../../context/AppContext'
import { Greeting } from './Greeting'

test('renderiza a saudação com o nome padrão do contexto', () => {
  render(
    <AppProvider>
      <Greeting />
    </AppProvider>,
  )

  expect(screen.getByText('Olá, visitante!')).toBeInTheDocument()
})
