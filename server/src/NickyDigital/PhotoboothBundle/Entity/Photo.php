<?php

namespace NickyDigital\PhotoboothBundle\Entity;

use Doctrine\ORM\Mapping as ORM;
use Gedmo\Mapping\Annotation as Gedmo;

/**
 * Photo
 *
 * @ORM\Table()
 * @ORM\Entity
 */
class Photo
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
	 * @ORM\ManyToOne(targetEntity="Event", inversedBy="photos")
	 */
	private $event;

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
	 * @ORM\OneToMany(targetEntity="FacebookShares", mappedBy="photo")
	 */
	protected $facebookShares;

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

	public function setEvent($event)
	{
		$this->event = $event;
	}

	public function getEvent()
	{
		return $this->event;
	}

	public function setFacebookShares($facebookShares)
	{
		$this->facebookShares = $facebookShares;
	}

	public function getFacebookShares()
	{
		return $this->facebookShares;
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
