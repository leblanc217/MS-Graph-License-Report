# MS-Graph-License-Report
PowerShell script using MS graph to get users assigned to specific Azure licenses

API call originally used the $filter param to do user filtering server side, however due to limitations of Graph API (confirmed by MS via support ticket) $filter can not be used with $select. Thus filtering is done client side.
