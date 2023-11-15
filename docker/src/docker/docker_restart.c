/*
 * ToastStunt Docker Restart
 *
 * Since the desired ToastStunt Docker container is optimized for size and security,
 * it has no shell. This code is intended to mimic the restart shell script in most
 * ways, acting as the jumping off point for Docker.
 *
 * Direct questions, comments, concerns, complaints, etc to lisdude <lisdude@lisdude.com>
 */

//#define VERBOSE

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>

#define MAX_ARGS        9               // Total number of potential arguments.
#define DEFAULT_PORT    "7777"          // Default listening port.
#define DATA_PATH       "/moo"          // The path to the database directory.
#define DEFAULT_UMASK   0077            // Default permissions to use.

int main(void) {
    char *arguments[MAX_ARGS];          // List of arguments (+1 for NULL)
    unsigned int argCount = 0;          // Current place in arguments list.
    char *source_database_name;         // Final determination of the source database name.
    char *destination_database_name;    // Final determination of the destination database name.

    // Read environment variables from Docker (or, I guess, wherever).
    const char *log_file = getenv("LOG_FILE");
    const char *database_source = getenv("DATABASE");
    const char *emergency = getenv("EMERGENCY");
    const char *additional_arguments = getenv("MISC_ARGS");

#ifdef VERBOSE
    printf("ToastStunt launcher started.\n");
#endif

    // args[0] should be the program:
    arguments[argCount++] = "./moo";

    // Emergency wizard mode:
    if (emergency != NULL)
        arguments[argCount++] = "-e";

    // Logfile:
    if (log_file != NULL) {
        arguments[argCount++] = "-l";
        arguments[argCount++] = (char*)log_file;
    }

    // Source database:
    if (database_source == NULL)
        asprintf(&source_database_name, "%s", "Minimal.db");
    else
        asprintf(&source_database_name, "%s/%s", DATA_PATH, database_source);

    if (access(source_database_name, F_OK) != 0) {
        printf("Database not found: %s\n", source_database_name);
        free(source_database_name);
        return 1;
    }

    arguments[argCount++] = source_database_name;

    // Destination database:
    asprintf(&destination_database_name, "%s.new", source_database_name);

    // If the .new database exists, move to .old and rename to .db
    if (access(destination_database_name, F_OK) == 0) {
        char *old_db_name;
        asprintf(&old_db_name, "%s.old", source_database_name);
        rename(source_database_name, old_db_name);
        rename(destination_database_name, source_database_name);
        free(old_db_name);
    }

    arguments[argCount++] = destination_database_name;

    // Add any miscellaneous arguments provided:
    arguments[argCount++] = (char*)additional_arguments;

    // Port:
    arguments[argCount++] = DEFAULT_PORT;

    // Mandatory end-of-args NULL:
    arguments[argCount++] = NULL;

    // Set the umask
    umask(DEFAULT_UMASK);

#ifdef VERBOSE
    printf("Executing command: ");
    for (unsigned int i = 0; i < argCount; i++) {
        printf(" %s", arguments[i]);
    }
    printf("\n");
#endif

    execvp("./moo", arguments);

    free(source_database_name);
    free(destination_database_name);

    /* No need to check the return value. If something goes wrong, this code will
     * continue executing. Thus we always print an error and return an error value.
     * Otherwise, the process would have been replaced and we will never get here. */
    perror("Error executing ./moo");

    return 1;
}

