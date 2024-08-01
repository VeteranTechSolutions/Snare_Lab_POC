# Snare Training Lab: Automated Active Directory Training Environment

Welcome to the Snare Training Lab, a fully automated and scalable Active Directory training environment deployed on Proxmox. This lab is designed to offer a hands-on learning experience for cybersecurity enthusiasts, particularly those interested in understanding and experimenting with Active Directory in a controlled setting.

## Why Create This Lab?

### Educational Purpose
Aims to provide a practical learning environment for students, educators, and professionals to explore Active Directory and cybersecurity concepts without the overhead of manual setup.

### Automation Focus
Utilizes modern automation tools like Packer, Terraform, and Ansible to streamline the deployment and management of virtual machines and infrastructure.

### Cost-Effective
Designed to be cost-effective, allowing users to experiment without incurring high expenses typically associated with physical or less dynamic virtual environments.

## Prerequisites

- **Proxmox Server:** Ensure you have access to a Proxmox server with adequate resources (CPU, RAM, Storage).
- **Network Configuration:** Proper network setup to allow seamless communication between the Proxmox server and client machines.
- **Access and Security:** Set up user roles and permissions correctly to manage the lab environment securely.

## Lab Deployment Steps

### Provisioning the Server
- Set up the Proxmox server with necessary storage and network configurations.
- Create API tokens and define privileges for automated tasks.

### Infrastructure Setup
- Use Packer to prepare and configure virtual machine templates.
- Deploy virtual machines using Terraform scripts that define the required infrastructure.
- Configure the machines using Ansible for role-specific settings such as Domain Controllers, Web Servers, etc.

### Access and Usage
- Detailed steps on how to access the lab once deployed.
- Guidelines on performing common tasks within the lab environment.

## Components of the Lab

- **Domain Controller (DC):** Central authentication server that manages users and computers in the domain.
- **Additional Domain Controllers (ADCS):** Provides redundancy and load balancing for the primary DC.
- **File Server (FS):** Manages file storage and access permissions within the network.
- **Web Server (WEB):** Hosts web applications and services for the lab environment.
- **Workstations (WS1 & WS2):** Client computers used for various user activities and testing.

## Security Considerations

- **Isolation:** Ensure the lab is isolated from production networks to prevent unintended access.
- **Monitoring:** Implement monitoring solutions to track lab usage and detect potential security incidents.
- **Updates and Patches:** Regularly update the operating systems and applications to protect against vulnerabilities.

## Future Enhancements

- Introduce more complex network scenarios with additional subnets and VPN configurations.
- Expand the lab to include Linux servers and cross-platform management tests.
- Implement automated red teaming exercises and attack simulations.

## Acknowledgments

- Thanks to the cybersecurity community for the tools and scripts that make such environments possible.
- Special thanks to contributors who have provided feedback and suggestions to improve the lab.

This knowledge base is intended to help users get started quickly and understand the purpose and structure of the Snare Training Lab. It's an evolving document that will be updated as the lab grows and improves.
