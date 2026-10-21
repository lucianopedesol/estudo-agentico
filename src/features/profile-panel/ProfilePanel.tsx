import { Avatar } from './Avatar'
import { Bio } from './Bio'
import { MemberSince } from './MemberSince'
import { ProfilePanelWrapper } from './ProfilePanel.styles'

export function ProfilePanel() {
  return (
    <ProfilePanelWrapper>
      <Avatar />
      <Bio />
      <MemberSince />
    </ProfilePanelWrapper>
  )
}
