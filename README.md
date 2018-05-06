# crostini-pie
Post install expedited, for Crostini. 

# What is this?
This is a simple bash script for setting up a container from scratch, after initial installation. It runs through a series of modular steps (called "ingredients in the script, because pie, geddit?), each of which does a fairly simple thing, like setting the host name of the container, setting up the Debian stretch backports repositories, as well as the contrib and non-free ones, and then installs a bunch of software, mostly with apt, but some of it using GNU stow.

**Important Disclaimer**
It has only been tested on my own PixelBook. It works for me. You should review the script to make sure it doesn't eat all your ice cream, run away with your dog, sleep with your truck, or otherwise ruin your life.

# Why would you use it?
I found myself often destroying and reinstalling containers, whether for trying things out, because of bugs, or whatever other reason. So repeatedly rebuilding all the tools I need for my daily work quickly became tiresome and time-consuming. 
My PixelBook is my daily driver and I need to be able to quickly restore from scratch and be up and running with a minimum of effort. 

Also, I tend to use software that is newer than what's available in Debian stretch (or simply isn't available at all). 
For my purposes, backports mostly does the job, but some things are built from source, or are simply binary downloads (like terraform). More details on what exactly the script builds below, but it's geared towards my own purposes, which is as a devops workstation. Should be easy to modify it for your own uses.


# How would you use it?
It's just a bash script. Since a new Crostini container doesn't have git, just download it with curl, and execute it (give it a read-through first).

```
curl -o crostini-pie.sh https://github.com/DictatorBob/crostini-pie/blob/master/crostini-pie.sh
bash crostini-pie.sh
```
# What exactly does it do?
First of all, for every step or function that it executes, it will prompt you first. If you don't want it to do a thing, simply reply to the prompt with a single lower-case "n". If you want it to do the thing, press Enter. You can also type in arguments for the function, if it needs any. For example, in the case of the terraform and packer installer, you can specify the version, and it will download/install exactly that.

When you run the script, it will:
1. Set the hostname for the container **guest**. It's not renaming the LXD container, which has to be named "penguin" for the Google-provided app shortcut to find it. It simply sets the hostname of your guest OS.
2. It creates new apt sources in /etc/apt/sources.list.d to make available additional Debian repos (backports, contrib, non-free). If you're a Free Software advocate, you should edit those appropriately (but of course, the PixelBook and ChromeOS are already not technically free software).
3. It adds a selection of software packages from the apt repos. In the shell script, these packages are defined in two lists: "required" and "optional". Those names are pretty self-explanatory. You won't be prompted for the stuff in the required list, but for every package listed in "optional" you'll have the opportunity to hit Enter to add it or "n" to skip it. It should be trivial to edit the script and add your own choices to the list
4. It installs termite from source. This happens to be my favourite terminal emulator. Skip it if you prefer another. The install script is more or less verbatim from here: https://github.com/Corwind/termite-install/blob/master/termite-install.sh. **Warning: Adds a lot of packages**
5. It installs emacs from source. This is a lengthy process, so skip if you're not an Emacs user. **Warning: Lengthy compile time, adds a lot of packages**
6. It installs terraform and packer (binary downloads) and ansible (from the official ansible ppa)

# Additional notes

 - It's meant to be idempotent, so in theory you can run and re-run the script as many times as you like
 - It should be trivially simple to add an ingredient. Just add the name of your ingredient to the list at the beginning. This name can be anything. Then add a "case" command under the function "add_ingredient"

