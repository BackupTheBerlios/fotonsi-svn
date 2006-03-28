#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <dlfcn.h>
#include <errno.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdarg.h>
#include <sys/utsname.h>
#include <sys/types.h>
#include <signal.h>


/* Funciones para uso de la propia librería */
static void _rstrip(char* cad)
{
    register char *c;
    for (c = cad; *c; c++) {
        if (*c == ' ' || *c == '\n' || *c == '\r') {
            *c = '\0';
            return;
        }
    }
}

/* Funciones originales */

typedef int (*type_fnmount)(const char*, const char*, const char*, unsigned long, const void*);
typedef int (*type_fnbind)(int, __CONST_SOCKADDR_ARG, socklen_t);
typedef int (*type_fnkill)(pid_t, int);

type_fnmount fnmount;
type_fnbind fnbind;
type_fnkill fnkill;

static void _init_funcs()
{
    static int loaded = 1;
    if (loaded) {
        void* dl = dlopen("libc.so.6", RTLD_LAZY);

        fnmount = (type_fnmount)dlsym(dl, "mount");
        fnbind = (type_fnbind)dlsym(dl, "bind");
        fnkill = (type_fnkill)dlsym(dl, "kill");

        dlclose(dl);
        loaded = 0;
    }
}

/* Para el registro */
static void _loggin(char* string, ...)  
{
    va_list va;
    FILE *f;
    
    if (!(f = fopen("/var/log/libfotonfake.log", "a")))
        return;

    va_start(va, string);
    vfprintf(f, string, va);
    va_end(va);

    fclose(f);
}


/* Sustitución código de esas funciones */

int mount(
        const char* fespecial, 
        const char* dir, 
        const char* tiposf, 
        unsigned long le, 
        const void* datos)
{

    /* mount
     *
     * mount es la primitiva que pide montar particiones. Lo que hacemos
     * aquí es denegar todas las peticiones de montar una partición.
     * En este caso, devolvemos el error EPERM (no tiene privilegios).
     *
     * Quizás pudiéramos dejar montar algunos tipos de patición, como proc o
     * devpts. El filtro lo haríamos mirando el valor que toma el argumento
     * tiposf.
     */

    _loggin("(mount) Intenta montar %s en %s\n", fespecial, dir);
    errno = EPERM;
    return -1;
}

int bind (
        int __fd, 
        __CONST_SOCKADDR_ARG __addr, 
        socklen_t __len)
{
    struct sockaddr_in* in;
    struct sockaddr_in replace;
    char ip[32];
    FILE* file;

    _init_funcs();


    /* bind
     *
     * Esta primitiva del kernel se usa para asociar un socket a un puerto e IP, de
     * manera que luego se pueda hacer un listen(2) de ese socket.
     *
     * Nuestro objetivo es que la peticiones de bind que vayan a la ip 0.0.0.0 (cualquier
     * dirección) se sustituyan por la IP colocada en el fichero /etc/fakefoton.ip.
     *
     * Para ello, primero comprobamos que la familia es AF_INET (TPC/IPv4, para IPv6 sería
     * AF_INET6), y luego comprobamos que esa dirección es la 0.0.0.0. De ser así, mandaremos
     * al bind(2) una petición modificada.
     */

    if (__addr->sa_family == AF_INET) {
        in = (struct sockaddr_in*)__addr;

        if (in->sin_addr.s_addr == INADDR_ANY) {
            _loggin("(bind) Intenta conectar a %s:%d.\n", inet_ntoa(in->sin_addr), (int)ntohs(in->sin_port));

            if ((file = fopen("/etc/chrb/ip", "r")))
            {
                fgets(ip, sizeof(ip), file);
                fclose(file);

                _rstrip(ip);

                memcpy(&replace, in, sizeof(replace));
                if (inet_aton(ip, &replace.sin_addr)) {
                    __addr = (struct sockaddr*)&replace;
                    _loggin("(bind) * Se cambia la IP de escucha a %s\n", ip);
                }
            }
        }
    }

    return fnbind(__fd, __addr, __len);
}


/* Sustitución de gethostname(2) para forzar que lea el nombre del host
 * siempre desde el fichero /etc/hostname
 */

int gethostname(char* cadena, size_t lon)
{
    FILE* f;

    if ((f = fopen("/etc/hostname", "r")))
    {
        fgets(cadena, lon, f);
        _rstrip(cadena);
        fclose(f);
    } else {
        struct utsname u;
        uname(&u);
        strncpy(cadena, u.nodename, lon);
    }

    return 0;
}

/* Sustitución de kill(2) para no que mande señales a procesos que no son del
 * propio chroot.
 *
 * Esta primitiva manda una señal a un determinado proceso. La verificación
 * que hacemos aquí es que ese proceso pertenezca al chroot del mismo proceso
 * que le manda la señal. Esta comprobación se hace mirando a dónde apunta el
 * enlace simbólico de /proc/PID/root.
 *
 * Si el /proc no está montado en /proc no se pondrá lanzar ninguna señal a 
 * ningún proceso.
 *
 * En caso de mandar una señal a un proceso que no es de su chroot, se le devuelve
 * el eror EPERM (permiso denegado).
 */
int kill(pid_t pid, int sig)
{
    char pathproc[32];
    char rootdir[128];

    _init_funcs();

    snprintf(pathproc, sizeof(pathproc), "/proc/%d/root", pid);
    if (readlink(pathproc, rootdir, sizeof(rootdir)) != 1) {
        errno = EPERM;
        return -1;
    }

    return fnkill(pid, sig);
}

