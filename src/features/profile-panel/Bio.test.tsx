import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Bio } from './Bio'

test('renderiza vazio por padrão, mostrando o placeholder', () => {
  render(<Bio />)
  const textarea = screen.getByPlaceholderText('Escreva algo sobre você...')
  expect(textarea).toBeInTheDocument()
  expect(textarea).toHaveValue('')
})

test('reflete o texto digitado imediatamente no campo', async () => {
  const user = userEvent.setup()
  render(<Bio />)
  const textarea = screen.getByPlaceholderText('Escreva algo sobre você...')
  await user.type(textarea, 'Gosto de React')
  expect(textarea).toHaveValue('Gosto de React')
})
