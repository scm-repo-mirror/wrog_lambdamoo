/* Copyright (c) 1998-2002 Ben Jackson (ben@ben.com).  All rights reserved.
 *
 * Use and copying of this software and preparation of derivative works based
 * upon this software are permitted provided this copyright notice remains
 * intact.
 *
 * THIS SOFTWARE IS PROVIDED BY BEN J JACKSON ``AS IS'' AND ANY
 * EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT BEN J JACKSON BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 * IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
 * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#ifndef Waif_H
#define Waif_H

#include "config.h"
#include "options.h"

#include "db_private.h"
#include "structures.h"


#define WAIF_PROP_PREFIX	':'
#define WAIF_VERB_PREFIX	':'

#ifdef WAIF_DICT
#  define  WAIF_INDEX_VERB	":_index"
#  define  WAIF_INDEXSET_VERB	":_set_index"
#endif

typedef struct Waif         Waif;
typedef struct WaifPropdefs WaifPropdefs;


/*--------------*
 |  WAIF_MAPSZ  |
 *--------------*/

/* Try to make struct Waif fit into 32 bytes with this mapsz.  These
 * bytes are probably "free" (from a powers-of-two allocator) and we
 * can use them to save lots of space.  With 64bit addresses I think
 * the right value is 8.  If checkpoints are unforked, save space for
 * an index used while saving.  Otherwise we can alias propdefs and
 * clobber it in the child.
 */
#ifdef UNFORKED_CHECKPOINTS
#  define WAIF_MAPSZ	2
#else
#  define WAIF_MAPSZ	3
#endif


/*---------------*
 |  struct Waif  |
 *---------------*/

/*................................
  :  begin DEC ALPHA experiment  :
  :  (see structures.h comment)  :
 */
#ifdef SHORT_ALPHA_VAR_POINTERS
#pragma pointer_size save
#pragma pointer_size short
#endif

struct Waif {
    Objid class;
    Objid owner;
    WaifPropdefs *propdefs;
    Var          *propvals;
    unsigned long map[WAIF_MAPSZ];

#ifdef UNFORKED_CHECKPOINTS
    unsigned long waif_save_index;
#else
#  define  waif_save_index  map[0]
#endif

};

#ifdef SHORT_ALPHA_VAR_POINTERS
#pragma pointer_size restore
#endif
/*
 :  end of DEC ALPHA experiment  :
 :...............................:*/


/*-----------------------*
 |  struct WaifPropdefs  |
 *-----------------------*/

struct WaifPropdefs {
    int		    refcount;
    int		    length;
    struct Propdef  defs[1];
};


extern void free_waif(Waif *);
extern Waif *dup_waif(Waif *);
extern enum error waif_get_prop(Waif *, const char *, Var *, Objid progr);
extern enum error waif_put_prop(Waif *, const char *, Var, Objid progr);
extern  int waif_bytes(Waif *);
extern void waif_before_saving(void);
extern void waif_after_saving(void);
extern void waif_before_loading(void);
extern void waif_after_loading(void);
extern void dbio_write_waif(Var);
extern  int dbio_read_waif(Var *);
extern void free_waif_propdefs(WaifPropdefs *);
extern void waif_rename_propdef(Object *, const char *, const char *);

#endif		/* Waif_H */
