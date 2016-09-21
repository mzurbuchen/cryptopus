node('buildnode') {
  def fpmHome   = tool('fpm')
  def fpm       = "${fpmHome}/bin/fpm"
  def pulp_repo = 'puzzle-autobuild-cryptopus2'
  def deploy_path   = "/var/www/vhosts"

  git('https://github.com/puzzle/cryptopus')
  sh """
    set -x
    ${fpmHome}/bin/fpm -s dir -t rpm -n cryptopus -m puzzle-itc --prefix ${deploy_path} .
    /usr/local/bin/upload_rpm_to_pulp.sh ${pulp_repo} *.rpm
    #rm -rf ./*.rpm
  """
  archive"${current_build}"
}
