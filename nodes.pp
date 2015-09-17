node /^demomq1.*/ {
  class{'dummy':}
}
node /^demomq[1-9]/ {
  class{'rabbitmq_host':}
}
