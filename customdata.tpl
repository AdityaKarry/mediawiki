#!/bin/bash
apt update -y 
sleep 10;
apt install ansible -y
sleep 10;
ansible-galaxy collection install community.mysql

sleep 30;
cat << EOG >> /home/buildaz/vars.yml
mediawiki_url: https://releases.wikimedia.org/mediawiki/1.41/mediawiki-1.41.0.tar.gz
tmp_dir: /tmp
mediawiki_path: /var/lib/mediawiki
apache_path: /var/www/html/mediawiki
default_conf: /etc/apache2/sites-enabled/000-default.conf
db_socket: /var/run/mysqld/mysqld.sock
dbname: mediawiki
db_user: mediawiki
db_password: #password#
EOG

sleep 5;
cat << EOF >> /home/buildaz/deploy.yml
## Media Wiki Installation

- hosts: localhost
  tasks:
    - name: Refernce variables
      include_vars:
        file: vars.yml
    - name: Install packages
      become: yes
      apt:
        pkg:
          - ansible
          - python3-mysqldb
          - apache2
          - mariadb-server
          - php
          - php-mysql
          - libapache2-mod-php
          - php-xml
          - php-mbstring
        state: present
        update_cache: yes
    - name: Download Mediawiki
      get_url:
        url: "{{ mediawiki_url }}"
        dest: "{{ tmp_dir }}"
    - name: Create Mediawiki Directory
      become: yes
      file:
        path: "{{ mediawiki_path }}"
        state: directory
    - name: Extract tar file
      become: yes
      unarchive:
        src: "{{ tmp_dir }}/mediawiki-1.41.0.tar.gz"
        dest: "{{ mediawiki_path }}"
    - name: Create softlink for Mediawiki
      become: yes
      file:
        src: "{{ mediawiki_path }}"
        dest: "{{ apache_path }}"
        state: link
    - name: Change default www path
      become: yes
      replace:
        path: "{{ default_conf }}"
        regexp: 'DocumentRoot \/var\/www\/html'
        replace: 'DocumentRoot /var/www/html/mediawiki'
    - name: Restart Apache2
      become: yes
      service:
        name: apache2
        state: restarted
        enabled: yes
    - name: Auto start MySQL
      become: yes
      service:
        name: mariadb
        state: started
        enabled: yes
    - name: Create MediawikiDB
      become: yes
      become_user: root
      community.mysql.mysql_db:
        login_unix_socket: "{{ db_socket }}"
        name: "{{ dbname }}"
        state: present
    - name: Create DB User
      become: yes
      become_user: root
      community.mysql.mysql_user:
        login_unix_socket: "{{ db_socket }}"
        state: present
        name: "{{ db_user }}"
        password: "{{ db_password }}"
        priv:
          'mediawiki.*:ALL,GRANT'
EOF

sleep 20;
inv="127.0.0.1"
ansible-playbook -i $inv /home/buildaz/deploy.yml