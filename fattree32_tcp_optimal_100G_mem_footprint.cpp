#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <iostream>
#include <string.h>

#define BUFFER_SIZE 1024

int main() {
    pid_t pid;
    const int command_num = 4;
    const char* m_commands[command_num] = { 
        "julia --project=. src/Tempus.jl fattree32_empiric_random_empiric_tcp_100G.json base",
        "julia --project=. src/Tempus.jl fattree32_empiric_random_empiric_tcp_100G.json paths",
        "julia --project=. src/Tempus.jl fattree32_empiric_random_empiric_tcp_100G.json ecs",
        "julia --project=. src/Tempus.jl fattree32_empiric_random_empiric_tcp_100G.json optimal" 
    };
    const char* outfile_name[command_num] = { 
        "./tempus_out/fattree32_empiric_random_empiric_tcp_base_mem_footprint.txt", 
        "./tempus_out/fattree32_empiric_random_empiric_tcp_paths_mem_footprint.txt", 
        "./tempus_out/fattree32_empiric_random_empiric_tcp_ecs_mem_footprint.txt", 
        "./tempus_out/fattree32_empiric_random_empiric_tcp_optimal_mem_footprint.txt" 
    };

    for (int i = 0; i < command_num; i++) {
        std::cout << "Running command: " << m_commands[i] << "\n";

        // Check if the file exists
        if (remove(outfile_name[i]) == 0) {
            printf("File '%s' removed successfully.\n", outfile_name[i]);
        } else {
            printf("Unable to remove file '%s'. It may not exist or there may be permission issues.\n", outfile_name[i]);
        }

        FILE *out_file = fopen(outfile_name[i], "w");

        if (out_file == NULL) {
            fprintf(stderr, "Failed to open file %s\n", outfile_name[i]);
            return 1;
        }

        fprintf(out_file, "Running command: %s\n\n\n", outfile_name[i]);

        // Fork a child process
        pid = fork();

        if (pid < 0) {
            // Fork failed
            fprintf(stderr, "Fork failed\n");
            return 1;
        } else if (pid == 0) {
            // Child process
            // Execute your bash command using exec
            execl("/bin/bash", "bash", "-c", m_commands[i], NULL);
            // If exec returns, it means there was an error
            perror("exec");
            exit(1);
        } else {
            // Parent process
            printf("Child process PID: %d\n", pid);
            printf("Parent process started with PID: %d\n", getpid());

            // Continuously monitor the status of the child process
            while (1) {
                int status;
                pid_t result = waitpid(pid, &status, WNOHANG);

                if (result == 0) {
                    printf("Child process with PID %d is still running\n", pid);
                } else if (result == -1) {
                    printf("Error occurred while waiting for child process\n");
                    break;
                } else {
                    if (WIFEXITED(status)) {
                        fprintf(out_file, "Child process exited normally with status: %d\n", WEXITSTATUS(status));
                        printf("Child process exited normally with status: %d\n", WEXITSTATUS(status));
                    } else if (WIFSIGNALED(status)) {
                        fprintf(out_file, "Child process terminated by signal: %d\n", WTERMSIG(status));
                        printf("Child process terminated by signal: %d\n", WTERMSIG(status));
                    }
                    break;
                }
                

                char filename[100];
                FILE *file;
                char buffer[BUFFER_SIZE];
                char *line;
                int vmRSS = -1;
                int vmHWM = -1;

                // Create the filename for the /proc/[pid]/status file
                snprintf(filename, sizeof(filename), "/proc/%d/status", pid);

                // Open the /proc/[pid]/status file
                file = fopen(filename, "r");
                if (file == NULL) {
                    perror("fopen");
                    return -1;
                }

                // Read the file line by line
                bool rss_read = false;
                bool hmw_read = false;
                while (fgets(buffer, BUFFER_SIZE, file) != NULL) {
                    // Search for the line starting with "VmRSS:" (Resident Set Size)
                    if (strncmp(buffer, "VmRSS:", 6) == 0) {
                        // Parse the memory usage value
                        line = strtok(buffer, " ");
                        line = strtok(NULL, " ");
                        vmRSS = atoi(line);
                        rss_read = true;
                    }
                    if (strncmp(buffer, "VmHWM:", 6) == 0) {
                        // Parse the memory usage value
                        line = strtok(buffer, " ");
                        line = strtok(NULL, " ");
                        vmHWM = atoi(line);
                        hmw_read = true;
                    }
                    if (rss_read && hmw_read) {
                        break;
                    }
                }

                // Close the file
                fclose(file);

                fprintf(out_file, "VMRSS: %d\n", vmRSS);
                fprintf(out_file, "vmHWM: %d\n", vmHWM);
                fprintf(out_file, "----------------------------------\n");
                std::cout << "VMRSS: " << vmRSS << "\n";
                std::cout << "VMHWM: " << vmHWM << "\n";

                sleep(1); // Sleep for 0.5 second before checking again
            }
            fclose(out_file);
        }
    }

    return 0;
}
