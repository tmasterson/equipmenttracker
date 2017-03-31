require 'rbcurse'
require 'rbcurse/core/widgets/tree/treemodel'

class TrackerTreeModel < DefaultTreeModel
    attr_accessor :treetodblink

    def root(*args, &block)
        super
        if !@root.is_a? TrackerNode
            n = TrackerNode.new @root
            @root = n
        end
        @root
    end

    def addlink(key, table, id)
        if @treetodblink.nil?
            @treetodblink = {}
        end
        @treetodblink[key] = {'table' => table, 'id' => id}
    end

    def getlinktable(key)
        $log.debug("treetodblink (#{key.class}), (#{key}), #{@treetodblink[key].inspect}")
        @treetodblink[key]['table']
    end

    def getlinkid(key)
        @treetodblink[key]['id']
    end

    def updatemodel(node, old_key, new_key)
        @treetodblink[new_key] = @treetodblink[old_key]
        @treetodblink.delete(old_key)
        node.updatenode(new_key)
    end

end
class TrackerNode < TreeNode

    def updatenode(new_object)
        @user_object = new_object
    end

    def root?
        parent.nil?
    end

end
