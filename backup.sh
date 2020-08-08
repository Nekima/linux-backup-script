#!/bin/bash

#####################
#                   #
#   CONFIGURATION   #  
#                   #
#####################



##############
#            #
#   DISQUE   #
#            #
##############

# Nom du disque monté ou la backup local s'enregistrera
disk='disque1'


##############
#            #
#  DOSSIERS  #
#            #
##############

# Sauvegarder WWW ?
www='false'

# Sauvegarder MARIADB ?
mariadb='true'

# Sauvegarder le dossier /SRV ?
srv='true'


##############
#            #
#   UPLOAD   #
#            #
##############

# Uploader la sauvegarde en offsite Google Cloud ?
offsite='true'

# Nom du bucket sur lequel upload
bucket='gs://testbucket/folder'


##############
#            #
#    RGPD    #
#            #
##############

# Définir une politque de suppression des données ?
policy='true'

# Combien de jours souhaitez vous conserver les sauvegardes ?
conservation='31'


##############
#            #
#  NEXTCLOUD #
#            #
##############

# Activer la sauvegarde de Nextcloud ?
nextcloud='true'

# Sur quel disque sauvegarder Nextcloud ?
nxdisk='disque3'

# Chemin de Nextcloud
nxpath='/mnt/disque2/nextcloud/'

# Définir politique de suppression des données ?
nxpolicy='true'

# Combien de jours souhaitez vous conserver les sauvegardes ?
nxconservation='3'

##############
#            #
# BCP CONFIG #
#            #
##############

# Sauvegardera les configurations des packages suivant:

# NGINX
bnginx='true'

# DHCPD
bdhcpd='true'

# PIHOLE
bpihole='true'

# SAMBA SRV
bsamba='true'

# PROFTPD
bproftpd='true'

# CRONTABS
bcrontabs='true'


#####################
#                   #
#       CODE        #
#                   #
#####################

# Déclaration de la date et l'heure de la sauvegarde
date=$(date +%d-%m-%Y-%H-%M)

# Créations des dossiers dans le disque
mkdir /mnt/$disk/backup
mkdir /mnt/$disk/backup/cfgs

if [ $www = "true" ]
    then
        echo "Sauvegarde du dossier WWW..."
        mkdir /mnt/$disk/backup/www
        tar -czf /mnt/$disk/backup/www/sites_$date.tgz -C /var/www .
        echo "Sauvegarde du dossier WWW terminé!"
    else
        echo "Sauvegarde du dossier WWW désactivé"
fi

if [ $mariadb = "true" ]
    then
        echo "Sauvegarde de MariaDB..."
        mkdir /mnt/$disk/backup/mysql
        tar -czf /mnt/$disk/backup/mysql/mysql_$date.tgz -C /var/lib/mysql .
        echo "Sauvegarde de MariaDB terminé!"
    else
        echo "Sauvegarde de MariaDB désactivé"
fi

if [ $srv = "true" ]
    then
        echo "Sauvegarde du dossier SRV..."
        mkdir /mnt/$disk/backup/srv
        tar --exclude='*.gma' --exclude='*.vpk' --exclude='*.bin' -czf /mnt/$disk/backup/srv/srv_$date.tgz -C /srv .
        echo "Sauvegarde du dossier SRV terminé!"
    else
        echo "Sauvegarde du dossier SRV désactivé"
fi

if [ $nextcloud = "true" ]
    then
        echo "Sauvegarde de Nextcloud..."
        mkdir /mnt/$nxdisk/nextcloud
        cp -avr $nxpath /mnt/$nxdisk/nextcloud/bckp_$date
        echo "Sauvegarde de Nextcloud terminée!"
    else
        echo "Sauvegarde de Nextcloud désactivée"
fi

if [ $bnginx = "true" ]
    then
        echo "Sauvegarde de la configuration d'NGINX."
        tar -czf /mnt/$disk/backup/cfgs/nginx_$date.tgz -C /etc/nginx .
        echo "Sauvegarde d'NGINX terminé!"
    else
        echo "Sauvegarde d'NGINX désactivé"
fi

if [ $bdhcpd = "true" ]
    then
        echo "Sauvegarde de la configuration de DHCPD."
        tar -czf /mnt/$disk/backup/cfgs/dhcp_$date.tgz -C /etc/dhcp .
        echo "Sauvegarde de DHCPD terminé!"
    else
        echo "Sauvegarde de DHCPD désactivé"
fi

if [ $bpihole = "true" ]
    then
        echo "Sauvegarde de la configuration de PIHOLE."
        tar -czf /mnt/$disk/backup/cfgs/pihole_$date.tgz -C /etc/pihole .
        echo "Sauvegarde de PIHOLE terminé!"
    else
        echo "Sauvegarde de PIHOLE désactivé"
fi

if [ $bsamba = "true" ]
    then
        echo "Sauvegarde de la configuration de SAMBA."
        tar -czf /mnt/$disk/backup/cfgs/samba_$date.tgz -C /etc/samba .
        echo "Sauvegarde de SAMBA terminé!"
    else
        echo "Sauvegarde de SAMBA désactivé"
fi

if [ $bproftpd = "true" ]
    then
        echo "Sauvegarde de la configuration de PROFTPD."
        cp /etc/proftpd.conf /mnt/$disk/backup/cfgs/proftpd_$date.conf
        echo "Sauvegarde de PROFTPD terminé!"
    else
        echo "Sauvegarde de PROFTPD désactivé"
fi

if [ $bcrontabs = "true" ]
    then
        echo "Sauvegarde des CRONTABS."
        tar -czf /mnt/$disk/backup/cfgs/crontab_$date.tgz -C /var/spool/cron .
        echo "Sauvegarde des CRONTABS terminée!"
    else
        echo "Sauvegarde des CRONTABS désactivée!"
fi

if [ $policy = "true" ]
    then
        echo "Suppression des fichiers datant de plus de" $conservation "jours"
        find /mnt/$disk/backup/mysql -name "*.tgz" -type f -mtime +$conservation -exec rm -f {} \;
        find /mnt/$disk/backup/www -name "*.tgz" -type f -mtime +$conservation -exec rm -f {} \;
        find /mnt/$disk/backup/srv -name "*.tgz" -type f -mtime +$conservation -exec rm -f {} \;
        find /mnt/$disk/backup/cfgs -name "*.tgz" -type f -mtime +$conservation -exec rm -f {} \;
        echo "Suppression terminée!"
    else
        echo "Pas de suppression automatique des fichiers"
fi

if [ $nxpolicy = "true" ]
    then
        echo "Suppression des sauvegardes de nextcloud datant de plus de " $nxconservation "jours"
        find /mnt/$nxdisk/nextcloud/* -type d -mtime +$nxconservation | xargs rm -rf
        echo "Suppression terminée!"
    else
        echo "Pas de suppression automatique des backups de Nextcloud"
fi

if [ $offsite = "true" ]
    then
        echo "Upload de la sauvegarde sur Google Cloud"
        gsutil cp /mnt/$disk/backup/mysql/mysql_$date.tgz $bucket/mysql
        gsutil cp /mnt/$disk/backup/www/sites_$date.tgz $bucket/www
        gsutil cp /mnt/$disk/backup/srv/srv_$date.tgz $bucket/srv
        gsutil cp /mnt/$disk/backup/cfgs/nginx_$date.tgz $bucket/cfgs/nginx
        gsutil cp /mnt/$disk/backup/cfgs/dhcp_$date.tgz $bucket/cfgs/dhcp
        gsutil cp /mnt/$disk/backup/cfgs/pihole_$date.tgz $bucket/cfgs/pihole
        gsutil cp /mnt/$disk/backup/cfgs/samba_$date.tgz $bucket/cfgs/samba
        gsutil cp /mnt/$disk/backup/cfgs/proftpd_$date.conf $bucket/cfgs/proftpd
        gsutil cp /mnt/$disk/backup/cfgs/crontab_$date.tgz $bucket/cfgs/crontab
        echo "Upload terminé!"
    else
        echo "Pas de sauvegarde sur Google Cloud"
fi

echo Finalisation et protection des sauvegardes
chmod -Rf 700 /mnt/$disk/backup/
chmod -Rf 700 /mnt/$nxdisk/backup/