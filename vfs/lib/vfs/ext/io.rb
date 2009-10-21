
class IO

  class << self

    alias_method :open_without_vfs, :open
    alias_method :read_without_vfs, :read

    def open(fd,mode_str='r', &block)
      return open(fd, mode_str, &block) if ::File.exist_without_vfs?( name )
      file = org.jboss.virtual.VFS.root( fd )
      stream = file.openStream()
      io = stream.to_io 
      block.call( io ) if block
      io
    end

    def read(name, length=nil, offset=nil)
      return read_without_vfs(name, length) if ::File.exist_without_vfs?( name )

      vfs_url, child_path = VFS.resolve_within_archive(name)
      raise ::Errno::ENOENT unless vfs_url

      virtual_file = Java::OrgJbossVirtual::VFS.root( vfs_url )
      virtual_file = virtual_file.getChild( child_path ) if child_path
      raise ::Errno::ENOENT unless virtual_file

      stream = virtual_file.openStream()
      io = stream.to_io 
      begin
        s = io.read
      ensure
        io.close()
      end
      s
    end
  end

end
