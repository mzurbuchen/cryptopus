node('buildnode') {
  def fpmHome   = tool('fpm')
  def fpm       = "${fpmHome}/bin/fpm"
  def pulp_repo = 'puzzle-autobuild-cryptopus2'
  def deploy_path   = "/var/www/vhosts"
  def current_build = "cryptopus-2.0-${BUILD_NUMBER}.x86_64.rpm"

  git('https://github.com/puzzle/cryptopus')
  sh """
    set -x
    ${fpmHome}/bin/fpm -s dir -t rpm -n ${current_build} -a x86_64 -m puzzle-itc --prefix ${deploy_path} .
    /usr/local/bin/upload_rpm_to_pulp.sh ${pulp_repo} ${current_build}
    #rm -rf ./*.rpm
  """
  archive"${current_build}"
}
