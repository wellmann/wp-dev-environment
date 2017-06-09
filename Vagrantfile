# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Author:: Kevin Wellmann <kevin@wellmann.io>

# Settings
local_ip = "192.168.33.10"
domains  = ["wordpress.dev", "www.wordpress.dev"]
database = "scotchbox"
webroot  = "wordpress"

# Read in all plugins
plugins = []
Dir.chdir "plugins"
Dir.glob("*").select { |plugin| plugins << plugin }

Dir.chdir ".."

# Read in all themes
themes = []
Dir.chdir "themes"
Dir.glob("*").select { |theme| themes << theme }

Vagrant.configure("2") do |config|

    config.vm.box = "scotch/box"
    config.ssh.username = "vagrant"
    config.ssh.password = "vagrant"
    config.vm.network "private_network", ip: local_ip
    config.vm.hostname = domains[0]

    # Enables automatic updating of hosts file
    if Vagrant.has_plugin?("vagrant-hostmanager")
        config.hostmanager.enabled = true
        config.hostmanager.manage_host = true
        # Unset hostname
        domains.delete_at(0)
        config.hostmanager.aliases = domains
    else
        puts "PLUGIN VAGRANT-HOSTMANAGER MISSING! RUN:"
        puts
        puts "vagrant plugin install vagrant-hostmanager"
        exit
    end

    config.vm.provision "shell", inline: <<-SHELL
    
      # Set webroot if not "public"
      webroot=#{webroot}
      if ! [ $webroot == "public" ]; then
        confs=("000-default scotchbox.local")
        for conf in "${confs[@]}"
        do
          sudo sed -i s,/var/www/public,/var/www/$webroot,g /etc/apache2/sites-available/$conf.conf
        done
      fi
    
      # Create symlinks for plugins
      plugins=(#{plugins.join(" ")})
      for plugin in "${plugins[@]}"
      do
      	sudo ln -s /var/www/plugins/$plugin /var/www/#{webroot}/wp-content/plugins/$plugin
      done
      
      # Create symlinks for themes
      themes=(#{themes.join(" ")})
      for theme in "${themes[@]}"
      do
        sudo ln -s /var/www/themes/$theme /var/www/#{webroot}/wp-content/themes/$theme
      done

      # Restart apache
      sudo service apache2 restart
      
    SHELL

    config.vm.synced_folder ".", "/var/www", :mount_options => ["dmode=777", "fmode=666"]

    if Vagrant.has_plugin?("vagrant-triggers")

        # Import sql dump on vagrant up (clear tables before)
        config.trigger.after [:up], :stdout => true, :force => true do
            if File.exist?("#{database}.sql")
                run_remote "mysql -u root -proot #{database} < /var/www/#{database}.sql"
            end
        end

        # Export sql dump on vagrant suspend, vagrant halt
        config.trigger.before [:suspend, :halt], :stdout => true, :force => true do
            run_remote "mysqldump -u root -proot #{database} > /var/www/#{database}.sql"
        end
    else
        puts "PLUGIN VAGRANT-TRIGGERS MISSING! RUN:"
        puts
        puts "vagrant plugin install vagrant-triggers"
        exit
    end

end