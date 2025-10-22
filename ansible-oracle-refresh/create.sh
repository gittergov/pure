#!/bin/bash
# Script to create Ansible role structure for Oracle Pure Storage refresh

# Create role directory structure
mkdir -p roles/oracle-pure-refresh/{tasks,handlers,templates,files,vars,defaults,meta}

# Create main tasks file
cat > roles/oracle-pure-refresh/tasks/main.yml << 'EOF'
---
# Main tasks for Oracle Pure Storage database refresh

- name: Pre-refresh validation
  import_tasks: pre_validation.yml
  tags: 
    - validation
    - pre_refresh

- name: Shutdown clone database
  import_tasks: shutdown_clone.yml
  tags:
    - shutdown
    - clone_operations

- name: Dismount ASM disk groups
  import_tasks: dismount_asm.yml
  tags:
    - asm
    - dismount

- name: Create and manage Pure Storage snapshot
  import_tasks: pure_snapshot.yml
  tags:
    - pure
    - snapshot

- name: Copy volumes from source to clone
  import_tasks: copy_volumes.yml
  tags:
    - pure
    - copy

- name: Mount ASM disk groups
  import_tasks: mount_asm.yml
  tags:
    - asm
    - mount

- name: Start clone database
  import_tasks: start_clone.yml
  tags:
    - startup
    - clone_operations

- name: Post-refresh validation
  import_tasks: post_validation.yml
  tags:
    - validation
    - post_refresh

- name: Cleanup old snapshots
  import_tasks: cleanup_snapshots.yml
  when: cleanup_old_snapshots | default(true)
  tags:
    - cleanup
    - maintenance
EOF

# Create pre-validation tasks
cat > roles/oracle-pure-refresh/tasks/pre_validation.yml << 'EOF'
---
# Pre-refresh validation tasks

- name: Check source database status
  oracle_db_status:
    hostname: "{{ source_host }}"
    service_name: "{{ oracle_sid }}"
    mode: normal
  register: source_db_status

- name: Verify source database is accessible
  assert:
    that:
      - source_db_status.status == "OPEN"
    fail_msg: "Source database is not in OPEN status"

- name: Check Pure Storage connectivity
  uri:
    url: "https://{{ flasharray_host }}/api/1.19/auth/session"
    method: POST
    body_format: json
    body:
      api_token: "{{ flasharray_password }}"
    validate_certs: no
  register: pure_auth
  delegate_to: localhost

- name: Verify protection group exists
  purestorage.flasharray.purefa_info:
    gather_subset:
      - pgroups
    fa_url: "{{ flasharray_host }}"
    api_token: "{{ flasharray_password }}"
  register: pgroup_info
  delegate_to: localhost

- name: Check if protection group exists
  assert:
    that:
      - protection_group in pgroup_info.purefa_info.pgroups
    fail_msg: "Protection group {{ protection_group }} not found"
EOF

# Create shutdown tasks
cat > roles/oracle-pure-refresh/tasks/shutdown_clone.yml << 'EOF'
---
# Shutdown clone database tasks

- name: Get current database status
  shell: |
    echo "SELECT status FROM v\$instance;" | sqlplus -s / as sysdba
  environment:
    ORACLE_HOME: "{{ oracle_home }}"
    ORACLE_SID: "{{ oracle_sid }}"
  register: db_status
  failed_when: false

- name: Shutdown database if running
  shell: |
    sqlplus -s / as sysdba << EOF
    WHENEVER SQLERROR EXIT SQL.SQLCODE
    SHUTDOWN IMMEDIATE;
    EXIT;
    EOF
  environment:
    ORACLE_HOME: "{{ oracle_home }}"
    ORACLE_SID: "{{ oracle_sid }}"
  when: "'OPEN' in db_status.stdout or 'MOUNTED' in db_status.stdout"
  register: shutdown_result

- name: Verify database is shut down
  shell: |
    ps -ef | grep -E "ora_pmon_{{ oracle_sid }}|ora_smon_{{ oracle_sid }}" | grep -v grep
  register: oracle_processes
  failed_when: oracle_processes.stdout != ""
  changed_when: false
EOF

# Create handlers
cat > roles/oracle-pure-refresh/handlers/main.yml << 'EOF'
---
# Handlers for Oracle Pure Storage refresh

- name: restart asm
  shell: |
    srvctl stop asm -f
    srvctl start asm
  environment:
    ORACLE_HOME: "{{ grid_home }}"
  become: yes
  become_user: root

- name: send notification
  mail:
    to: "{{ item }}"
    subject: "Oracle DB Refresh Status - {{ ansible_hostname }}"
    body: |
      Database refresh has been completed.
      
      Status: {{ refresh_status | default('Unknown') }}
      Time: {{ ansible_date_time.iso8601 }}
      Source: {{ source_host }}
      Clone: {{ clone_host }}
  loop: "{{ notification_emails }}"
  when: send_notifications | default(false)

- name: cleanup logs
  find:
    paths: "{{ log_directory }}"
    age: "{{ log_retention_days }}d"
    recurse: yes
  register: old_logs

- name: remove old logs
  file:
    path: "{{ item.path }}"
    state: absent
  loop: "{{ old_logs.files }}"
EOF

echo "Role structure created successfully!"
echo "To use this role, include it in your playbook like:"
echo ""
echo "- hosts: oracle_clone"
echo "  roles:"
echo "    - oracle-pure-refresh"
