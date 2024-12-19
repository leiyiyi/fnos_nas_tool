#!/usr/bin/bash
set -e
UNAME_M="$(uname -m)"
readonly UNAME_M

UNAME_U="$(uname -s)"
readonly UNAME_U

# COLORS
readonly COLOUR_RESET='\e[0m'
readonly aCOLOUR=(
    '\e[38;5;154m' # 绿色 - 用于行、项目符号和分隔符 0
    '\e[1m'        # 粗体白色 - 用于主要描述
    '\e[90m'       # 灰色 - 用于版权信息
    '\e[91m'       # 红色 - 用于更新通知警告
    '\e[33m'       # 黄色 - 用于强调
    '\e[34m'       # 蓝色
    '\e[35m'       # 品红
    '\e[36m'       # 青色
    '\e[37m'       # 浅灰色
    '\e[92m'       # 浅绿色9
    '\e[93m'       # 浅黄色
    '\e[94m'       # 浅蓝色
    '\e[95m'       # 浅品红
    '\e[96m'       # 浅青色
    '\e[97m'       # 白色
    '\e[40m'       # 背景黑色
    '\e[41m'       # 背景红色
    '\e[42m'       # 背景绿色
    '\e[43m'       # 背景黄色
    '\e[44m'       # 背景蓝色19
    '\e[45m'       # 背景品红
    '\e[46m'       # 背景青色21
    '\e[47m'       # 背景浅灰色
)

readonly GREEN_LINE=" ${aCOLOUR[0]}─────────────────────────────────────────────────────$COLOUR_RESET"
readonly GREEN_BULLET=" ${aCOLOUR[0]}-$COLOUR_RESET"
readonly GREEN_SEPARATOR="${aCOLOUR[0]}:$COLOUR_RESET"

Show() {
    # OK
    if (($1 == 0)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[0]}  OK  $COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
    # FAILED
    elif (($1 == 1)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[3]}FAILED$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
        exit 1
    # INFO
    elif (($1 == 2)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[0]} INFO $COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
    # NOTICE
    elif (($1 == 3)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[4]}NOTICE$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
    fi
}

Warn() {
    echo -e "${aCOLOUR[3]}$1$COLOUR_RESET"
}

GreyStart() {
    echo -e "${aCOLOUR[2]}\c"
}

ColorReset() {
    echo -e "$COLOUR_RESET\c"
}
# 定义红色文本
RED='\033[0;31m'
# 无颜色
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW="\e[33m"

declare -a menu_options
declare -A commands
menu_options=( 
	"显示本机全部ntfs格式硬盘"
	"手动挂载单个分区"
	"列出全部磁盘及其分区信息"	
	"查看单个分区信息"
	"手动编辑/etc/fstab文件"	
	"手动编辑SMB共享文件夹"
	"测试全部挂载分区"
	"1分钟后关闭屏幕"
	
)

commands=(
    ["显示本机全部ntfs格式硬盘"]="display_all_ntfs"
	["手动挂载单个分区"]="mount_disk_partitions"
	["列出全部磁盘及其分区信息"]="display_disk_info"
	["查看单个分区信息"]="view_disk_info"
	["手动编辑/etc/fstab文件"]="view_fstab_file"    
	["手动编辑SMB共享文件夹"]="edit_smb_conf"
	["测试全部挂载分区"]="test_disk_mount"
	["1分钟后关闭屏幕"]="off_display"

)
#显示本机全部ntfs格式硬盘
display_all_ntfs() {

# 使用lsblk命令获取磁盘信息
# lsblk_output=$(lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT)
 
# 使用grep命令筛选出FSTYPE为ntfs的行
# ntfs_disks=$(echo "$lsblk_output" | grep "ntfs")
 
# 打印磁盘名称
# echo "$ntfs_disks" | awk '{print $1}'

lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT | grep "ntfs"

}

#1分钟后关闭屏幕
off_display() {
	sudo setterm -blank 1
}

#手动编辑SMB共享文件夹
edit_smb_conf() {
	sudo nano /etc/samba/users/laorenshen.share.conf
}
# 手动编辑/etc/fstab文件
view_fstab_file() {
	sudo nano /etc/fstab
}

# 查看单个分区信息
view_disk_info() {
	# 提示用户输入要格式化的分区名称
	read -p "请输入要查看的磁盘分区（例如：sda1 或 /dev/sdb1）： " PARTITION

	# 如果用户输入的不是以 /dev/ 开头，则加上 /dev/
	if [[ "$PARTITION" != /dev/* ]]; then
		PARTITION="/dev/$PARTITION"
	fi
	disk_info=$(sudo blkid "${PARTITION}")
	echo "${disk_info}" 
}

# 测试全部挂载分区
test_disk_mount() {
	echo "测试挂载..."
	sudo mount -a
	echo "测试完成"
}

# 手动挂载单个分区
mount_disk_partitions() {
# 列出所有磁盘及其分区信息
echo "当前系统中的磁盘和分区信息："
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT

# 提示用户输入要格式化的分区名称
read -p "请输入要挂载的磁盘分区（例如：sda1 或 /dev/sdb1）： " PARTITION

# 如果用户输入的不是以 /dev/ 开头，则加上 /dev/
if [[ "$PARTITION" != /dev/* ]]; then
  PARTITION="/dev/$PARTITION"
fi
 
# 获取分区的基本名称
# BASENAME=$(basename "$PARTITION")
# 检查用户输入的分区是否存在
#if lsblk | grep -q "^${BASENAME}"; then
if blkid | grep -q "^${PARTITION}"; then
  # 确认操作
  read -p "您确定要挂载这块硬盘 ${PARTITION} 吗？ (y/n): " CONFIRM
  if [ "$CONFIRM" != "y" ]; then
    echo "操作已取消。"
    exit 1
  fi

  # 提示用户输入挂载点目录
  read -p "请输入要挂载的目录名字（例如：ST240G）： " MOUNT_DIR

  # 创建挂载点目录
  MOUNT_POINT="/media/laorenshen/${MOUNT_DIR}"
  
  # 检查挂载点目录是否存在，如果不存在则创建
  if [ ! -d "$MOUNT_POINT" ]; then
    echo "创建挂载点目录 ${MOUNT_POINT} ..."
    sudo mkdir -p "$MOUNT_POINT"
  fi

  # 卸载分区（如果已挂载）
  if mount | grep -q "^${PARTITION} "; then
    echo "正在卸载 ${PARTITION} ..."
    sudo umount "${PARTITION}"
  fi

  # 挂载分区
  echo "正在挂载 ${PARTITION} 到 ${MOUNT_POINT} ..."
  sudo mount "${PARTITION}" "$MOUNT_POINT"

  # 确认挂载成功
  if mount | grep -q "^${PARTITION} "; then
    echo "${PARTITION} 已成功挂载到 ${MOUNT_POINT}。"
    
         # 写入 /etc/fstab 以便系统重启后自动挂载
        read -p "您确定要写入/etc/fstab以便系统重启后自动挂载 ${PARTITION} 吗？ (y/n): " CONFIRM
  	    if [ "$CONFIRM" == "y" ]; then
                   
    		echo "正在将挂载信息写入 /etc/fstab ..."
			UUID=$(sudo blkid -s UUID -o value "${PARTITION}")
			FILE_TYPE=$(sudo blkid -s TYPE -o value "${PARTITION}")
    		FSTAB_ENTRY="UUID=${UUID} ${MOUNT_POINT} ${FILE_TYPE} defaults 0 0"
    
    		if ! grep -qs "${FSTAB_ENTRY}" /etc/fstab; then
    		  echo "${FSTAB_ENTRY}" | sudo tee -a /etc/fstab
    		  echo "挂载信息已写入 /etc/fstab。"
    		else
    		  echo "挂载信息已存在于 /etc/fstab。"
    		fi          
            
			echo "测试挂载..."
			sudo mount -a			
        fi   
	
		 # 生成共享文件夹配置
        read -p "您确定要SMB共享这个硬盘分区 ${MOUNT_DIR} 吗？ (y/n): " CONFIRM
  	    if [ "$CONFIRM" == "y" ]; then                   
    		
			
    		smb_conf="include = /etc/samba/users/laorenshen.share.conf"    
			 #sudo nano /etc/samba/smb.conf
			 #include = /etc/samba/users/%Y.timas.conf	
			 #/etc/samba/users/laorenshen.share.conf	
    		if ! grep -qs "${smb_conf}" /etc/samba/smb.conf; then
    		  echo "${smb_conf}" | sudo tee -a /etc/samba/smb.conf
    		  echo "SMB共享信息已写入 /etc/samba/smb.conf。"
    		else
    		  echo "SMB共享信息已存在于 /etc/samba/smb.conf。"
    		fi   
			
			# 检查/etc/samba/users/laorenshen.share.conf是否存在
			# 如果不存在，就创建一个新的配置文件			 
			#CONFIG_FILE="/etc/samba/users/laorenshen.share.conf"
			 
			# if [ ! -e "/etc/samba/users/laorenshen.share.conf" ]; then
				# echo "文件不存在，现在创建新的配置文件"
				# 以下是一个示例的配置文件内容 
				# 检查是否已经有ST2T这个smb共享，如果没有，则添加新的共享
				if ! grep -q "${MOUNT_DIR}" /etc/samba/users/laorenshen.share.conf; then
					echo "[${MOUNT_DIR}]" >> /etc/samba/users/laorenshen.share.conf
					echo "   path = /media/laorenshen/${MOUNT_DIR}" >> /etc/samba/users/laorenshen.share.conf					
					echo "   browsable = yes" >> /etc/samba/users/laorenshen.share.conf
					echo "   available = yes" >> /etc/samba/users/laorenshen.share.conf
					echo "   writeable = yes" >> /etc/samba/users/laorenshen.share.conf
					echo "   hide special files = yes" >> /etc/samba/users/laorenshen.share.conf
					echo "   hide unreadable = yes" >> /etc/samba/users/laorenshen.share.conf
					echo "   comment = System default shared folder" >> /etc/samba/users/laorenshen.share.conf
					
				fi
				echo "ok"
				
			# else
				# echo "文件已存在，不需要创建"
			# fi			
            
					
        fi   
    
  else
    echo "挂载失败。"
  fi
else
  echo "错误：未找到指定的分区 ${PARTITION}。"
  exit 1
fi

}

# 列出全部磁盘及其分区信息
display_disk_info() {   
	echo "当前系统中的磁盘和分区信息："
	lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT -P
}
show_menu() {
    clear
    YELLOW="\e[33m"
    NO_COLOR="\e[0m"

    echo -e "${GREEN_LINE}"
    echo '
    ***********  laorenshen NAS 工具箱v2.0  ***************
    适配系统: 飞牛os  fnOS 0.8.27
    开源地址： https://github.com/laorenshen/fnos_nas_tool
    '
    
    echo -e "${GREEN_LINE}"
    echo "请选择操作："

    # 特殊处理的项数组
    special_items=("设置虚拟机开机自启动(headless)" "VirtualBox硬盘直通" "创建root身份的VirtualBox图标" "刷新虚拟硬盘的UUID")
    for i in "${!menu_options[@]}"; do
        if [[ " ${special_items[*]} " =~ " ${menu_options[i]} " ]]; then
            # 如果当前项在特殊处理项数组中，使用特殊颜色
            echo -e "$((i + 1)). ${aCOLOUR[7]}${menu_options[i]}${NO_COLOR}"
        else
            # 否则，使用普通格式
            echo "$((i + 1)). ${menu_options[i]}"
        fi
    done
}

handle_choice() {
    local choice=$1
    # 检查输入是否为空
    if [[ -z $choice ]]; then
        echo -e "${RED}输入不能为空，请重新选择。${NC}"
        return
    fi

    # 检查输入是否为数字
    if ! [[ $choice =~ ^[0-9]+$ ]]; then
        echo -e "${RED}请输入有效数字!${NC}"
        return
    fi

    # 检查数字是否在有效范围内
    if [[ $choice -lt 1 ]] || [[ $choice -gt ${#menu_options[@]} ]]; then
        echo -e "${RED}选项超出范围!${NC}"
        echo -e "${YELLOW}请输入 1 到 ${#menu_options[@]} 之间的数字。${NC}"
        return
    fi

    # 执行命令
    if [ -z "${commands[${menu_options[$choice - 1]}]}" ]; then
        echo -e "${RED}无效选项，请重新选择。${NC}"
        return
    fi

    "${commands[${menu_options[$choice - 1]}]}"
}

while true; do
    show_menu
    read -p "请输入选项的序号(输入q退出): " choice
    if [[ $choice == 'q' ]]; then
        break
    fi
    handle_choice $choice
    echo "按任意键继续..."
    read -n 1 # 等待用户按键
done

