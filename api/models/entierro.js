/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('entierro', {
		id_entierro: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_entierro::regclass)",
			primaryKey: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: true
		},
		tipo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_espacio_nombre: {
			type: DataTypes.STRING,
			allowNull: true,
			references: {
				model: 'espacio_entierro',
				key: 'nombre'
			}
		},
		estructura: {
			type: DataTypes.STRING,
			allowNull: true
		},
		forma: {
			type: DataTypes.STRING,
			allowNull: true
		},
		largo: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		ancho: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		profundidad: {
			type: DataTypes.DOUBLE,
			allowNull: true
		},
		fecha: {
			type: DataTypes.DATE,
			allowNull: true
		},
		observaciones: {
			type: DataTypes.STRING,
			allowNull: true
		},
		cal: {
			type: DataTypes.STRING,
			allowNull: true
		},
		papv: {
			type: DataTypes.STRING,
			allowNull: true
		},
		contexto: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_lugar_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'lugar',
				key: 'id_lugar'
			}
		},
		precision_lugar: {
			type: DataTypes.STRING,
			allowNull: true
		}
	}, {
		tableName: 'entierro',
		timestamps: false
	});
};
