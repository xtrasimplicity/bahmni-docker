FROM centos:6.9

RUN yum install -y python-setuptools openssh sudo && \
    yum install -y https://dl.bintray.com/bahmni/rpm/rpms/bahmni-installer-0.91-70.noarch.rpm

RUN curl -L https://goo.gl/R8ekg5 >> /etc/bahmni-installer/setup.yml

# Ignore Selinux tasks
RUN echo '---' > /opt/bahmni-installer/bahmni-playbooks/roles/selinux/tasks/main.yml

# Mock SSH server config, to keep the installer happy.
RUN mkdir -p /etc/ssh && \
    touch /etc/ssh/sshd_config && \
    echo -e '#!/bin/sh\necho "This is a fake SSH service. It does not do anything."' > /etc/init.d/sshd && \
    chmod +x /etc/init.d/sshd

# Mock `iptables`, to keep the installer happy.
RUN mv /sbin/iptables /sbin/iptables-old && \
  echo -e '#!/bin/sh\necho "This is not the real iptables. If you *really* need to, you can use /sbin/iptables-old."' > /sbin/iptables && \
  chmod +x /sbin/iptables && \
  echo -e '#!/bin/sh\necho "This is a fake iptables service. It does not do anything."' > /etc/init.d/iptables && \
  chmod +x /etc/init.d/iptables

RUN bahmni -i local install

RUN yum install -y telnet
ADD artifacts/bin/start_bahmni /usr/sbin/
RUN chmod +x /usr/sbin/start_bahmni

EXPOSE 80 443 8069

VOLUME /var/www /var/log /var/lib/mysql /home/bahmni /etc/bahmni-installer/deployment-artifacts

CMD [ "/usr/sbin/start_bahmni" ]