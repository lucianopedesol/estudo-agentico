import { useAppContext } from '../../context/AppContext'
import { AvatarCircle } from './Avatar.styles'

function getInitials(name: string): string {
  const words = name.trim().split(/\s+/).filter(Boolean)
  if (words.length === 0) return ''
  if (words.length === 1) return words[0][0].toUpperCase()
  return (words[0][0] + words[words.length - 1][0]).toUpperCase()
}

export function Avatar() {
  const { userName } = useAppContext()
  return <AvatarCircle>{getInitials(userName)}</AvatarCircle>
}
