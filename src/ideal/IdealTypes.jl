###############################################################################
#
#   IdealSet/sideal 
#
###############################################################################

const IdealSetID = Dict{Ring, Set}()

type IdealSet{T <: Nemo.RingElem} <: Set
   base_ring::PolyRing

   function IdealSet{T}(R::PolyRing) where T
      if haskey(IdealSetID, R)
         return IdealSetID[R]
      else
         return IdealSetID[R] = new(R)
      end
   end
end

type sideal{T <: Nemo.RingElem} <: Module{T}
   ptr::libSingular.ideal
   base_ring::PolyRing
   isGB::Bool

   function sideal{T}(R::PolyRing, ids::spoly...) where T
      n = length(ids)
      id = libSingular.idInit(Cint(n))
      z = new(id, R, false)
      R.refcount += 1
      finalizer(z, _sideal_clear_fn)
      for i = 1:n
         p = libSingular.p_Copy(ids[i].ptr, R.ptr)
         libSingular.setindex!(id, p, Cint(i - 1))
      end
      return z
   end

   function sideal{T}(R::PolyRing, id::libSingular.ideal) where T
      z = new(id, R, false)
      R.refcount += 1
      finalizer(z, _sideal_clear_fn)
      return z
   end
end

function _sideal_clear_fn(I::sideal)
   R = I.base_ring
   libSingular.id_Delete(I.ptr, R.ptr)
   _PolyRing_clear_fn
end
