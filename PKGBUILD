#    Copyright (C) 2022 7thCore
#    This file is part of AvnSrv-Script.
#
#    SfSrv-Script is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    SfSrv-Script is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

pkgname=sfsrv-script
pkgver=1.0
pkgrel=1
pkgdesc='Satisfactory server script for running the server on linux.'
arch=('x86_64')
license=('GPL3')
depends=('bash'
         'coreutils'
         'sudo'
         'grep'
         'sed'
         'awk'
         'curl'
         'rsync'
         'wget'
         'findutils'
         'tmux'
         'jq'
         'zip'
         'unzip'
         'p7zip'
         'postfix'
         's-nail'
         'steamcmd')
install=sfsrv-script.install
source=('bash_profile'
        'sfsrv-mkdir-tmpfs@.service'
        'sfsrv-script.bash'
        'sfsrv-send-notification@.service'
        'sfsrv@.service'
        'sfsrv-timer-1.service'
        'sfsrv-timer-1.timer'
        'sfsrv-timer-2.service'
        'sfsrv-timer-2.timer'
        'sfsrv-tmpfs@.service')
sha256sums=('f1e2f643b81b27d16fe79e0563e39c597ce42621ae7c2433fd5b70f1eeab5d63'
            '2b5c790ee74f0a123c05bbfe632a9c0cf6be28baa3bdc29f47eac4850fdca83e'
            'e54c62f88bb82de22a79abfc36970bc9dd41964ab73eb4c03b86064e900b7d75'
            'b372bba5101c13c04148724dc56f2686906bbeb919883d33c76b2101e8286ee2'
            '276381a26c03bb5b7549cbd2b02bd3537f20a2543387e876161995efbd50eb6a'
            '9de872b1fbaa9de17efad7c837b24f7a78099bd8a2a53cc2a01d733ff98ed5eb'
            'e125c9e09ded898d17a0cebc8364c18be197151933e6b8a9aa07c6a32cf15f46'
            '7cbf79572aa190bdb52017c4b2036f8bb98c281248c4b270fdec43df2cd80f69'
            'd1bac7525488894cfdaabb0965c77ecb27e5844ba8b2aed56ee40c7c072e368e'
            'b0c9d03ab897d187430996bc0458b9e5a0fb76b14730d4fa158e66901d6ec18a')

package() {
  install -d -m0755 "${pkgdir}/usr/bin"
  install -d -m0755 "${pkgdir}/srv/sfsrv"
  install -d -m0755 "${pkgdir}/srv/sfsrv/server"
  install -d -m0755 "${pkgdir}/srv/sfsrv/config"
  install -d -m0755 "${pkgdir}/srv/sfsrv/environments"
  install -d -m0755 "${pkgdir}/srv/sfsrv/updates"
  install -d -m0755 "${pkgdir}/srv/sfsrv/backups"
  install -d -m0755 "${pkgdir}/srv/sfsrv/logs"
  install -d -m0755 "${pkgdir}/srv/sfsrv/tmpfs"
  install -d -m0755 "${pkgdir}/srv/sfsrv/.config"
  install -d -m0755 "${pkgdir}/srv/sfsrv/.config/systemd"
  install -d -m0755 "${pkgdir}/srv/sfsrv/.config/systemd/user"
  install -D -Dm755 "${srcdir}/sfsrv-script.bash" "${pkgdir}/usr/bin/sfsrv-script"
  install -D -Dm755 "${srcdir}/sfsrv-timer-1.timer" "${pkgdir}/srv/sfsrv/.config/systemd/user/sfsrv-timer-1.timer"
  install -D -Dm755 "${srcdir}/sfsrv-timer-1.service" "${pkgdir}/srv/sfsrv/.config/systemd/user/sfsrv-timer-1.service"
  install -D -Dm755 "${srcdir}/sfsrv-timer-2.timer" "${pkgdir}/srv/sfsrv/.config/systemd/user/sfsrv-timer-2.timer"
  install -D -Dm755 "${srcdir}/sfsrv-timer-2.service" "${pkgdir}/srv/sfsrv/.config/systemd/user/sfsrv-timer-2.service"
  install -D -Dm755 "${srcdir}/sfsrv-send-notification@.service" "${pkgdir}/srv/sfsrv/.config/systemd/user/sfsrv-send-notification@.service"
  install -D -Dm755 "${srcdir}/sfsrv@.service" "${pkgdir}/srv/sfsrv/.config/systemd/user/sfsrv@.service"
  install -D -Dm755 "${srcdir}/sfsrv-mkdir-tmpfs@.service" "${pkgdir}/srv/sfsrv/.config/systemd/user/sfsrv-mkdir-tmpfs@.service"
  install -D -Dm755 "${srcdir}/sfsrv-tmpfs@.service" "${pkgdir}/srv/sfsrv/.config/systemd/user/sfsrv-tmpfs@.service"
  install -D -Dm755 "${srcdir}/bash_profile" "${pkgdir}/srv/sfsrv/.bash_profile"
}
