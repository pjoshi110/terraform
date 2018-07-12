node {
  env.PATH += ":/usr/local/bin/"
  checkout scm

  docker.build(env.JOB_NAME).inside {
    yum install tree
  }
}
