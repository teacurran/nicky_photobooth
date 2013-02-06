<?php

namespace NickyDigital\PhotoboothBundle\Entity;

use Doctrine\ORM\Mapping as ORM;
use Gedmo\Mapping\Annotation as Gedmo;

/**
 * Event
 *
 * @ORM\Table()
 * @ORM\Entity
 */
class Event
{
	/**
	 * @var integer
	 *
	 * @ORM\Column(name="id", type="integer")
	 * @ORM\Id
	 * @ORM\GeneratedValue(strategy="AUTO")
	 */
	private $id;

	/**
	 * @ORM\OneToMany(targetEntity="Photo", mappedBy="event")
	 */
	protected $photos;

	// TODO: figure out why Timestampable isn't populating
	/**
	 * @var datetime $created
	 *
	 * @Gedmo\Timestampable(on="create")
	 * @ORM\Column(type="datetime", nullable=true)
	 */
	protected $created;

	// TODO: figure out why Timestampable isn't populating
	/**
	 * @var datetime $updated
	 *
	 * @Gedmo\Timestampable(on="update")
	 * @ORM\Column(type="datetime", nullable=true)
	 */
	protected $updated;

	/**
	 * @param \NickyDigital\PhotoboothBundle\Entity\datetime $created
	 */
	public function setCreated($created)
	{
		$this->created = $created;
	}

	/**
	 * @return \NickyDigital\PhotoboothBundle\Entity\datetime
	 */
	public function getCreated()
	{
		return $this->created;
	}

	/**
	 * @param int $id
	 */
	public function setId($id)
	{
		$this->id = $id;
	}

	/**
	 * @return int
	 */
	public function getId()
	{
		return $this->id;
	}

	public function setPhotos($photos)
	{
		$this->photos = $photos;
	}

	public function getPhotos()
	{
		return $this->photos;
	}

	/**
	 * @param \NickyDigital\PhotoboothBundle\Entity\datetime $updated
	 */
	public function setUpdated($updated)
	{
		$this->updated = $updated;
	}

	/**
	 * @return \NickyDigital\PhotoboothBundle\Entity\datetime
	 */
	public function getUpdated()
	{
		return $this->updated;
	}


	
}
