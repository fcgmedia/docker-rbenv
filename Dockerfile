FROM base

MAINTAINER tcnksm "https://github.com/tcnksm"

# Install packages for building ruby
RUN apt-get update
RUN apt-get install -y --force-yes build-essential curl git
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev
RUN apt-get clean
WORKDIR /root

# Install rbenv and ruby-build
RUN git clone https://github.com/sstephenson/rbenv.git .rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git .rbenv/plugins/ruby-build
RUN .rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> .bashrc

# Install multiple versions of ruby
ENV CONFIGURE_OPTS --disable-install-doc
ADD versions.txt versions.txt
RUN xargs -L 1 rbenv install < versions.txt

# Install Bundler for each version of ruby
RUN echo 'gem: --no-rdoc --no-ri' >> .gemrc
RUN bash -l -c 'for v in $(cat /root/versions.txt); do rbenv global $v; gem install bundler; done'
