# How To Develop

## Build ediarum.DB

To build ediarum web ANT is used (see <https://ant.apache.org/manual/>).

### Prepare repo

After cloning the repo some adjustments have to be made:

- Set your system properties in `project.properties`:
  1. Add an empty file `project.properties` to `.`.
  2. Add the following lines with the parameters of your system:

     ```txt
     exist.dir=/eXist-db-5-2-0
     ```

- You have to install the antcontrib library (<http://ant-contrib.sourceforge.net/>)
  1. Download from: <https://sourceforge.net/projects/ant-contrib/files/ant-contrib/ant-contrib-1.0b2/ant-contrib-1.0b2-bin.zip/download>
  2. Unpack `ant-contrib` folder to `./lib/ant-contrib`.

### Build

To build the app one can use the command:

```bash
ant build-xar
```
