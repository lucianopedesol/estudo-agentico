import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
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

test('atualiza a saudação ao digitar um nome no input', async () => {
  const user = userEvent.setup()
  render(
    <AppProvider>
      <Greeting />
    </AppProvider>,
  )

  const input = screen.getByLabelText('Seu nome')
  await user.type(input, 'Ana')

  expect(screen.getByText('Olá, Ana!')).toBeInTheDocument()
})

test('volta para "visitante" se o campo for limpo', async () => {
  const user = userEvent.setup()
  render(
    <AppProvider>
      <Greeting />
    </AppProvider>,
  )

  const input = screen.getByLabelText('Seu nome')
  await user.type(input, 'Ana')
  await user.clear(input)

  expect(screen.getByText('Olá, visitante!')).toBeInTheDocument()
})

test('mostra "0 caracteres" quando o campo está vazio', () => {
  render(
    <AppProvider>
      <Greeting />
    </AppProvider>,
  )

  expect(screen.getByText('0 caracteres')).toBeInTheDocument()
})

test('mostra "3 caracteres" ao digitar "Ana"', async () => {
  const user = userEvent.setup()
  render(
    <AppProvider>
      <Greeting />
    </AppProvider>,
  )

  const input = screen.getByLabelText('Seu nome')
  await user.type(input, 'Ana')

  expect(screen.getByText('3 caracteres')).toBeInTheDocument()
})
