# Working to understand if the iQuery Mesh is healthy
tmsh show gtm iquery | grep -E 'Gtm::IQuery:|State|Data Center|Server' | awk '/Gtm::IQuery:/{ip=$2} /Server/{server=$3} /Data Center/{dc=$3" "$4} /State/{state=$2; if (state == "not-connected" || state == "connecting") print ip, server, state, dc}' | sort -k4

tmsh show gtm iquery field-fmt raw | (echo -e "IP_Address|Server_Name|Server_Type|Data_Center|State" && awk

# Inventory of table
# tmctl -C gtm_iqmgmt_stat
# show me the servers in the iquery that are not in a connected state
tmctl gtm_iqmgmt_stat -w 120 -s ip,server_name,dc_name,state -K dc_name | awk 'NR <= 2 || $4 != 2'
tmctl gtm_iqmgmt_stat -w 120 -s ip,server_name,dc_name,state -K dc_name | awk -F',' 'NR<=2 || $4!=0 {split($1,b,":"); ip=sprintf("%d.%d.%d.%d",strtonum("0x"b[13]),strtonum("0x"b[14]),strtonum("0x"b[15]),strtonum("0x"b[16])); $1=ip; OFS=","; print}'

