import { createContext, useContext, useState, type ReactNode } from 'react'

interface AppContextValue {
  userName: string
  setUserName: (name: string) => void
}

const AppContext = createContext<AppContextValue | undefined>(undefined)

export function AppProvider({ children }: { children: ReactNode }) {
  const [userName, setUserName] = useState('visitante')

  return (
    <AppContext.Provider value={{ userName, setUserName }}>
      {children}
    </AppContext.Provider>
  )
}

export function useAppContext() {
  const context = useContext(AppContext)
  if (!context) {
    throw new Error('useAppContext precisa ser usado dentro de um AppProvider')
  }
  return context
}
