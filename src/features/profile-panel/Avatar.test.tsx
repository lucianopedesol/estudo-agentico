import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { AppProvider } from '../../context/AppContext'
import { Avatar } from './Avatar'
import { Greeting } from '../greeting/Greeting'

test('mostra "V" para o nome padrão "visitante"', () => {
  render(
    <AppProvider>
      <Avatar />
    </AppProvider>,
  )
  expect(screen.getByText('V')).toBeInTheDocument()
})

test('mostra a inicial do nome quando há uma só palavra', async () => {
  const user = userEvent.setup()
  render(
    <AppProvider>
      <Greeting />
      <Avatar />
    </AppProvider>,
  )
  const input = screen.getByLabelText('Seu nome')
  await user.type(input, 'Ana')
  expect(screen.getByText('A')).toBeInTheDocument()
})

test('mostra a inicial da primeira e última palavra com nome composto', async () => {
  const user = userEvent.setup()
  render(
    <AppProvider>
      <Greeting />
      <Avatar />
    </AppProvider>,
  )
  const input = screen.getByLabelText('Seu nome')
  await user.type(input, 'Ana Souza')
  expect(screen.getByText('AS')).toBeInTheDocument()
})
