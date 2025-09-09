# 2025/09/08
## macOS 配置环境记录
1. 安装brew
2. 安装Applite(brew cask GUI软件)下面的软件可以用Applite搜索安装
3. 安装warp
4. 安装iTerm
5. 安装oh-my-zsh
配置zshrc
```bash
# fzf
brew install fzf
echo "source <(fzf --zsh)" >> ${ZDOTDIR:-$HOME}/.zshrc

# zsh-syntax-highlighting
brew install zsh-syntax-highlighting
echo "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

# zsh-autosuggestions
brew install zsh-autosuggestions
echo "source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

# starship
brew install starship
brew install font-hack-nerd-font 需要换nerd字体
echo "eval "$(starship init zsh)"" >> ${ZDOTDIR:-$HOME}/.zshrc

# 修改.zshrc
# 上面用brew安装的就不用在下面plugins里加了(除了fzf)，如果用git clone的方式安装的就要在下面plugins里加上
plugins=(git z vi-mode fzf) 

```
一些别名和函数
```bash
#
# Zsh command aliases
#
 ​
alias ls='ls -F --color'
alias grep='grep --color'
alias mkdir='mkdir -pv'

#
# eza
#
alias l='eza --classify --color-scale --icons=always --group-directories-first --time-style long-iso'
alias ll='eza --classify --color-scale --icons=always --group-directories-first --time-style long-iso --long -a --show-symlinks'
alias lsg='eza --classify --color-scale --icons=always --group-directories-first --time-style long-iso --git-ignore --git --git-repos'
alias llg='eza --classify --color-scale --icons=always --group-directories-first --time-style long-iso --git-ignore --git --git-repos --long'
alias llt='eza --classify --color-scale --icons=always --group-directories-first --time-style long-iso -l -a --show-symlinks --total-size'
 ​
#
# Utility functions
#
 ​
# Copy the contents of a file to the clipboard.
#
# copyfile <file_pathname>
function copyfile {
  cat $1 | pbcopy
}

# Copies the path of given directory or file to the clipboard.
# Copy current directory if no parameter.
function copypath {
  # If no argument passed, use current directory
  local file="${1:-.}"

  # If argument is not an absolute path, prepend $PWD
  [[ $file = /* ]] || file="$PWD/$file"

  # Copy the absolute path without resolving symlinks
  # If clipcopy fails, exit the function with an error
  print -n "${file:a}" | pbcopy || return 1

  echo ${(%):-"%B${file:a}%b copied to clipboard."}
}
#
 # Proxy
 #
 ​
 function proxy {
   proxy_host='127.0.0.1'
   proxy_port=<port>
   http_proxy_url="http://$proxy_host:$proxy_port"
   socks5_proxy_url="socks5://$proxy_host:$proxy_port"
 ​
   export http_proxy=$http_proxy_url
   export HTTP_PROXY=$http_proxy_url
   export https_proxy=$http_proxy_url
   export HTTPS_PROXY=$http_proxy_url
   export all_proxy=$socks5_proxy_url
   export ALL_PROXY=$socks5_proxy_url
 }
 ​
 function unproxy {
   unset http_proxy
   unset HTTP_PROXY
   unset https_proxy
   unset HTTPS_PROXY
   unset all_proxy
   unset ALL_PROXY
 }
```
也可以用 [zsh-snap](https://github.com/marlonrichert/zsh-snap) 管理插件

7. 安装tmux并配置
```bash
brew install tmux
# 安装oh-my-tmux
curl -fsSL "https://github.com/gpakosz/.tmux/raw/refs/heads/master/install.sh#$(date +%s)" | bash
```

8. 安装vim并配置
```bash
brew install vim
cp config/vim/vimrc ~/.vimrc
# vimrc设置打开系统剪切板
set clipboard=unnamedplus
```

## 软件推荐
1. GUI软件
- Applite
- vscode
- Warp
- Mos（鼠标滚轮优化软件）
- AppCleaner
- Snipaste
- ima
- ClashX
- inna

## 参考链接
- [环境配置指南前置 – macOS 终端](https://zhuanlan.zhihu.com/p/678611475)
- [在Mac下有什么好的终端？](https://www.zhihu.com/question/21776404/answer/2630267890)