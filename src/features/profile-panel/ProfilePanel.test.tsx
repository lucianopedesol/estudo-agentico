import { render, screen } from '@testing-library/react'
import { AppProvider } from '../../context/AppContext'
import { ProfilePanel } from './ProfilePanel'

test('renderiza o painel com o avatar visível', () => {
  render(
    <AppProvider>
      <ProfilePanel />
    </AppProvider>,
  )
  expect(screen.getByText('V')).toBeInTheDocument()
})
