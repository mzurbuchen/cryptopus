node('buildnode') {
  def fpmHome   = tool('fpm')
  def fpm       = "${fpmHome}/bin/fpm"
  def pulp_repo = 'puzzle-autobuild-cryptopus2'
  def deploy_path   = "/var/www/vhosts"

  git('https://github.com/puzzle/cryptopus')
  sh """
    set -x
    rm -rf ./*.rpm
    ${fpmHome}/bin/fpm -s dir -t rpm -n cryptopus -m puzzle-itc -v 2.0.${env.BUILD_NUMBER}-1 --prefix ${deploy_path} .
    /usr/local/bin/upload_rpm_to_pulp.sh ${pulp_repo} *.rpm
  """
}
