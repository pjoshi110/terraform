node {
  env.PATH += ":/usr/local/bin/"
  checkout scm

  docker.build(env.JOB_NAME).inside {
    # run any scripts or such here
    # sh 'script/ci'
  }
}
