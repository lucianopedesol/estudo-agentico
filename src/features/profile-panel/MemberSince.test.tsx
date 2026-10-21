import { render, screen } from '@testing-library/react'
import { MemberSince } from './MemberSince'

test('renderiza o texto "Membro desde Outubro de 2026"', () => {
  render(<MemberSince />)
  expect(screen.getByText('Membro desde Outubro de 2026')).toBeInTheDocument()
})
