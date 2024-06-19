FROM openexplorer/ai_toolchain_ubuntu_20_j5_gpu:v1.1.68

LABEL maintainer="tianws <tianwenshan@foxmail.com>"

# 设置apt、conda、pip代理镜像
# RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && apt-get clean && \
#     /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ && \
#     /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ && \
#     /opt/conda/bin/conda config --set show_channel_urls yes && \
#     /opt/conda/bin/pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 开启终端色彩
ENV TERM=xterm-256color

# 制作完整版 ubuntu
RUN export DEBIAN_FRONTEND=noninteractive && \
    bash -c 'yes | unminimize'

# apt安装常用软件
RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         ca-certificates \
         libjpeg-dev \
         libpng-dev \
         sudo \
         openssh-server \
         bash-completion \
         vim \
#         vim-gnome \
         zsh \
         tmux \
         ranger \
         xsel \
         mediainfo \
         proxychains4 \
         feh \
         apt-transport-https && \
         rm -rf /var/lib/apt/lists/*

# 设置X11转发(把/etc/ssh/sshd_config 中的X11Forwarding置为yes,X11UseLocalhost置为no)
RUN sed -i "s/^.*X11Forwarding.*$/X11Forwarding yes/" /etc/ssh/sshd_config && \
    sed -i "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" /etc/ssh/sshd_config

# # 新建用户并用 fixuid 管理 uid
# ENV USERNAME="docker"
# ENV PASSWD="123456"
# RUN useradd --create-home --no-log-init --shell /bin/zsh ${USERNAME} && \
#     adduser ${USERNAME} sudo && \
#     echo "${USERNAME}:${PASSWD}" | chpasswd
# RUN USER=${USERNAME} && \
#     GROUP=${USERNAME} && \
#     curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4.1/fixuid-0.4.1-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
#     chown root:root /usr/local/bin/fixuid && \
#     chmod 4755 /usr/local/bin/fixuid && \
#     mkdir -p /etc/fixuid && \
#     printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml
# 
# USER ${USERNAME}:${USERNAME}
# 
WORKDIR /root

 # 安装配置oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
     curl "https://raw.githubusercontent.com/tianws/config/master/zsh/themes/robbyrussell.zsh-theme-server" -o .oh-my-zsh/custom/themes/robbyrussell.zsh-theme && \
     git clone https://github.com/zsh-users/zsh-autosuggestions .oh-my-zsh/custom/plugins/zsh-autosuggestions && \
     git clone https://github.com/zsh-users/zsh-syntax-highlighting.git .oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
     sed -i "s/^plugins=.*$/plugins=(git colorize z zsh-autosuggestions zsh-syntax-highlighting)/" .zshrc

# 配置环境变量，使ssh连接时env也生效
RUN sed -i '$a\export $(cat /proc/1/environ |tr "\\0" "\\n" | xargs)' ~/.zshrc

# 配置vim
RUN curl "https://raw.githubusercontent.com/tianws/config/master/vim/vimrc" -o .vimrc

# 配置tmux
RUN curl "https://raw.githubusercontent.com/tianws/config/master/tmux/tmux_server.conf" -o .tmux.conf

# # 配置ranger
# RUN ranger --copy-config=all && \
#     curl "https://raw.githubusercontent.com/tianws/config/master/ranger/rc.conf" -o .config/ranger/rc.conf && \
#     curl "https://raw.githubusercontent.com/tianws/config/master/ranger/scope.sh" -o .config/ranger/scope.sh

#修改/etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
RUN sed -i "s/#UseDNS.*/UseDNS no/g" /etc/ssh/sshd_config
RUN sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

# 生成sshkey
# 添加公钥(如果没有公钥可以省略)
RUN mkdir /root/.ssh
# RUN echo 'ssh-rsa YOU_PUB_KEY' > /root/authorized_keys
# RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
# RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
# RUN rm /etc/ssh/ssh_host_rsa_key && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
# RUN rm /etc/ssh/ssh_host_ecdsa_key && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
# RUN rm /etc/ssh/ssh_host_ed25519_key && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key  -N ''
RUN mkdir /var/run/sshd

# Create an SSH user
# RUN useradd -rm -d /home/sshuser -s /bin/bash -g root -G sudo -u 1000 sshuser
# Set the SSH user's password (replace "password" with your desired password)
# RUN echo 'sshuser:password' | chpasswd

#变更root密码
RUN echo "root:111111"|chpasswd
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
# ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

RUN chsh -s $(which zsh)

# ENTRYPOINT ["fixuid"]
# CMD echo ${PASSWD} | sudo -S service ssh start && /bin/zsh
# CMD ["sh", "-c", "/usr/sbin/sshd && tail -f /dev/null"]
#运行脚本，启动sshd服务
# CMD ["/usr/sbin/sshd", "-D"]
# CMD ["/bin/zsh"]
