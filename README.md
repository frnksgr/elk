ELK Stack for CF Application Logs
=================================

* Build it with '''docker build -t frnksgr/elk .'''
* Run it with '''docker-compose up'''
* To use it 
    * create a CF security group providing access to your docker host on port 5000
    * create a CF user provided service
      ''' cf create-user-provided-service elk -l syslog/<your docker host as seen from CF apps>:5000
    * bind it to your applicaion(s) you want to monitor
      ''' cf bind-service <myapp> elk* 
    * start a browser to access kibana on http://<your docker host>:5601
    * create default index loggregator-*
